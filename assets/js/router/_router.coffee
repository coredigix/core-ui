###*
 * Router
 * @optional @param {Boolean} options.caseSensitive - if path is case sensitive @default false
 * @optional @param {Boolean} options.ignoreTrailingSlash - ignore trailing slash @default true
 * @optional @param {Number} options.cacheMax - cache max entries @default 100
 * @optional @param {function} options.out - called when quiting page
 * @optional @param {function} options.catch - called when error happend: Example: {code:404}
###
ROUTER_ROOT_PATH= -1	# Is document root path (Document real path)
HISTORY_NO_STATE= 0	# do not insert state in history, use when calling history.back()
HISTORY_REPLACE= 1	# do replace in history instead of adding
HISTORY_BACK= 2	# prevent history push when back
ROUTER_OPTIONS= Symbol 'Router options'
class Router
	constructor: (options)->
		# root path node
		if referrer= document.referrer
			@location= referrer= new URL referrer
		@referrer= referrer
		# Router id, used when calling ajax
		@id= 'rtr-' + (Router.ID_GEN++) # Router id
		# create route tree
		if options
			@out= options.out
			@catch= options.catch
		else
			options= {}
		@tree= new RouterTree options
		# prevent back and do an other action like closing popups
		@_back= []
		# Pop state
		_popstateListener= (event)=>
			# call callbacks
			preventBack= no
			for cb in @_back
				try
					break if preventBack= cb event
				catch err
					Core.fatalError 'Router', err
			if preventBack
				history.pushState event.state, '', @location.href
			else
				path= event.state?.path
				if typeof path is 'string'
					@goto path, HISTORY_BACK
			return
		window.addEventListener 'popstate', _popstateListener, off
		# start router
		$ => @goto document.location.href, ROUTER_ROOT_PATH
		return
	@ID_GEN: 0	# used to generate router ids
	###*
	 * Wrap
	###
	wrap: (route, wrapperFx)->
		@tree.wrap route, wrapperFx
		this # chain
	###*
	 * Param
	###
	param: (options)->
		throw "Illegal arg" unless arguments.length is 1 and options
		@tree.param options
		this # chain
	###*
	 * Has route
	###
	has: (route)-> @tree.has route

	###*
	 * Get
	###
	get: (route, options)->
		throw new Error 'Expected two arguments' unless arguments.length is 2
		# prepare controller
		if typeof options is 'function'
			options= in: options
		else unless options and typeof options is 'object'
			throw new Error 'Illegal options'
		# add node
		if Array.isArray route
			for rt in route
				node= @tree.add rt
				throw new Error "Route already set: #{route}" if node[ROUTER_OPTIONS]
				node[ROUTER_OPTIONS]= options
		else
			node= @tree.add route
			throw new Error "Route already set: #{route}" if node[ROUTER_OPTIONS]
			node[ROUTER_OPTIONS]= options
		this # chain
	###*
	 * Reload
	###
	reload: (forced)->
		if forced
			if typeof @out is 'function'
				@out @location, true
			else
				document.location.replace @location
		else
			@goto @location
		this # chain
	###*
	 * Goto
	###
	goto: (url, doState)->
		try
			# convert URL
			url= (new URL url, Core.baseURL) unless url instanceof URL
			# previous
			previousNode= @_node
			if previousLocation= @location
				previousPath= previousLocation.pathname
				@referrer= previousLocation
			# create context var
			path=		url.pathname
			@location=	url
			ctx=
				isRoot:			doState is ROUTER_ROOT_PATH
				url:			url
				path:			path
				isHistoryBack:	doState is HISTORY_BACK # if this is fired by history.back
				isNew:			(doState is ROUTER_ROOT_PATH) or (path isnt previousPath)
				params:			_create null	# Path params
				query:			_create null	# Query params
				history:		path: url.href
				route:			null
				options:		null
				# referrer
				referrer:		previousLocation
				referrerOptions: previousNode?[ROUTER_OPTIONS]
			# lookup for new Node
			tree= @tree
			resp= tree.resolve path # [cacheLRU, node, param1, value1, ...]
			@_node= node= resp[1]	# node
			ctx.route= node['/route']	# matched route
			# Path params
			params= ctx.params
			i=2
			len= resp.length
			while i < len
				params[resp[i++]]= resp[i++]
			# Query params
			params= ctx.query
			url.searchParams.forEach (v, k)->
				if v2= params[k]
					if Array.isArray(v2)
						v2.push v
					else
						params[k]= [v2, v]
				else
					params[k]=v
			# resolve params
			await tree.resolveParams ctx.params
			await tree.resolveParams ctx.query
			# call previous node out
			if previousNode
				await previousNode.out? ctx
				await previousNode.outOnce? ctx if ctx.isNew
			# push in history
			urlHref= url.href
			unless (doState in [HISTORY_BACK, ROUTER_ROOT_PATH]) or (previousLocation and urlHref is previousLocation.href) # do not push if it's history back or same URL
				historyState= path: urlHref
				if doState is HISTORY_REPLACE
					history?.replaceState historyState, '', urlHref
				else unless doState is HISTORY_NO_STATE
					history?.pushState historyState, '', urlHref
			# call listeners
			if (wrappers= node['/w']) and wrappers.length
				wrapperI= 0
				wrapperNext= =>
					if wrapperI < wrappers.length
						return wrappers[wrapperI++] ctx, wrapperNext
					else
						return _routerGotoLast this, node, ctx
				await wrapperNext()
			else
				await _routerGotoLast this, node, ctx
		catch err
			if typeof @catch is 'function'
				@catch err, ctx
			else
				Core.fatalError 'Router', err
		return
	###*
	 * Replace
	###
	replace: (url)-> @goto url, HISTORY_REPLACE
	###*
	 * History back cb
	###
	back: -> 
		if (url= @referrer) and url.href.startsWith Core.baseURL
			history.back()
		else
			@goto ''
	onBack: (cb)->
		throw new Error 'Expected 1 argument as function' unless arguments.length is 1 and typeof cb is 'function'
		@_back.push cb
		this # chain
_defineProperty Core, 'Router', value: Router

# exec Goto last step
_routerGotoLast= (router, node, ctx)->
	nodeOptions= node[ROUTER_OPTIONS]
	if ctx.isNew
		# abort active xhr calls
		Core.ajax.abort router.id
		# toggle <html> classes
		referrerOptions= ctx.referrerOptions
		$html= $('html')
		$html.removeClass referrerOptions.toggleClass if referrerOptions && referrerOptions.toggleClass
		$html.addClass nodeOptions.toggleClass if nodeOptions.toggleClass
		# go top
		if nodeOptions.scrollTop
			scrollTo 0,0
		# call current node in once
		await nodeOptions.once? ctx
	# call in
	await nodeOptions.in? ctx
	return