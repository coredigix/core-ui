###*
 * ROUTER
 * @attribute location	- equals: new URL document.location.href
 * 
 * @method  get
 *          @param {String|List<String>} path - path to controller
 *          @param {String} title - document title
 *          @param {String} toggleClass - HTML toggle class 
 *          @param {Boolean} scrollTop - if scroll page to top when matching this 
 *          @param {function} in - Cb each time we call this route
 *          @param {function} once - Cb this route once until changed
 *          @param {function} out- Cb when quit this controller
 *
 * @method alias 'path1', path2	# create alias from path1 to path2
 * @method alias 'path1', (ctx)=> "path2"	# create alias from path1 to path2
 *
 * @method  pushState url	# push state without calling routing
 *
 * @method goto url				# Goto this URL, if no match, this URL will be called effectively
 *
 *
 * Supported paths
 * 	- Static paths (relative or absolute): /example/of/static/path
 * 	- Static paths (relative or absolute): /example/o:f/st:atic/::path  => /example/o:f/st:atic/:path
 * 	- Static paths (relative or absolute): /example/o:f/st:atic/::path  => /example/o:f/st:atic/:path
 * 	- Dynamic paths (relative or absolutes): /example/of/:varname/dynamic/:var2
###
HISTORY_NO_STATE= 0	# do not insert state in history, use when calling history.back()
HISTORY_REPLACE= 1	# do replace in history instead of adding
HISTORY_BACK= 2	# prevent history push when back
Core.Router= class Router
	constructor: ()->
		# root path node
		@location= location= new URL document.referrer or document.location.href
		# private
		@_root= _newPathNode()
		@_$= _create null # params
		@_path= null # current path
		@_href= null # current href: used to not add new entry to history if some URL
		@_pathArr= [] # current path nodes as [pathKey, node, ...]
		@_back= [] # prevent back and do an other action like closing popups
		@_node= null # current node
		@id= 'r' + Math.random().toString(32).substr(2) # Router id
		@_ctx= null
		@_use= [] # queue cb; @see this.use
		@_post= [] # post call callbacks
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
		$ =>
			@replace document.location.href, false
		return
	###*
	 * call those functions whenever route changed
	###
	use: (cb)->
		@_use.push cb
		this # chain
	# post call
	postCall: (cb)->
		@_post.push cb
		this # chain
	###*
	 * Add params
	 * @param {String} options.name - param name
	 * @param {Regex|function} matches - param regex
	 * @param {function} resolver - async Resolver
	###
	param: (options)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
			name= options.name
			params= @_$
			throw 'Name expected string' unless typeof name is 'string'
			throw "Param already set: #{name}" if params[name]
			# matches
			matches= options.matches
			if matches
				if typeof matches is 'function'
					matches= test: matches
				else unless matches instanceof RegExp
					throw 'options.matches expected regex or function'
			# add
			params[name]=[name, matches, options.resolver]
		catch err
			err= new Error "Router.param>> " + err if typeof err is 'string'
			throw err
		return this	# chain
	###*
	 * GET
	###
	get: (options)->
		try
			# check if alias
			if options.alias and (options.in or options.out or options.once)
				throw 'Could not set alias and [in, out, once] at the same time' 
			# check arguments
			throw 'Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
			# parse path
			path= options.path
			if typeof path is 'string'
				_createNodeFromPath @_root, path, options
			else if Array.isArray path
				for p in path
					throw 'all paths expected string' unless typeof p is 'string'
					_createNodeFromPath @_root, p, options
			else
				throw 'Illegal options.path'
		catch err
			err= new Error "Router.GET>> " + err if typeof err is 'string'
			throw err
		this # chain
	# create alias
	# alias: (path, aliasPath)->
	# 	@get
	# 		path: path
	# 		alias: aliasPath
	###*
	 * Goto url
	 * @param {String|URL} url - target URL
	 * @optional @param {Boolean} doForword - unless false, forword to url if not mapped @default true
	###
	replace: (url, doForword)-> @goto url, HISTORY_REPLACE, doForword
	###*
	 * Goto url
	 * @param {String|URL} url - target URL
	 * @optional @param {Number} doState - internal use
	 * @optional @param {Boolean} doForword - unless false, forword to url if not mapped @default true
	###
	goto: (url, doState, doForword)->
		try
			# convert URL
			url= (new URL url, Core.baseURL) unless url instanceof URL
			# create context var
			referrer=	@location.href
			path=		url.pathname
			@location=	url
			ctx=
				referrer:		referrer
				url:			url
				path:			path
				isHistoryBack:	doState is HISTORY_BACK # if this is fired by history.back
				isNew:			yes
				params:			_create null
				history:		path: url.href
			@_ctx= ctx	
			# if the same path, return
			if path is @_path
				node= @_node
				ctx.isNew= no
				await @_node.in? ctx, node
			# lookup for pathname
			else
				@_path= url.pathname
				# abort active xhr calls
				Core.ajax.abort @id
				# previous node
				previousNode= @_node
				# lookup for new Node
				node= _lookupURI @_root, @_$, path, ctx.params
				@_node= node
				# call out on previous node
				if previousNode
					await previousNode.out? ctx, previousNode, node
					if a= previousNode.toggleClass
						$('html').removeClass a
				# call use function
				for cb in @_use
					await cb ctx, node, previousNode
				# exec new Node
				if node
					# set title
					if a= node.title
						a= a ctx if typeof a is 'function'
						document.title= 'kechExpress - ' + a
					# toggleClass
					if a= node.toggleClass
						$('html').addClass a
					# go top
					if node.scrollTop
						scrollTo 0,0
					# call once
					await node.once? ctx, node, previousNode
					# call In
					await node.in? ctx, node, previousNode
				else unless doForword is false
					return document.location.replace url.href
			# push in history
			urlHref= url.href
			unless (doState is HISTORY_BACK) or (urlHref is @_href) # do not push if it's history back
				docTitle= node?.title or ''
				if doState is HISTORY_REPLACE
					history?.replaceState ctx.history, docTitle, urlHref
				else unless doState is HISTORY_NO_STATE
					history?.pushState ctx.history, docTitle, urlHref
			unless urlHref is @_href
				@_href= urlHref
			# post calls
			for cb in @_post
				cb ctx, node
		catch err
			if err?
				if err is 404 # URL not found
					unless doForword is false
						document.location.href= url.href
				else if err is 403 # access denied
					Core.fatalError 'ROUTER', 'Access denied to: ' + urlHref
					await Core.alert i18n.err403, 'danger'
					@goto '' # go back to home
				else if err.aborted
					# do nothing, request aborted
				else if err.status is 0 # offline
					Core.alert i18n.noConnection, 'danger'
				else
					Core.fatalError 'ROUTER', err
					await Core.alert i18n.internalError, 'danger'
					@goto '' # go back to home
			else
				Core.fatalError 'ajaxCatcher', 'null Error!'
				await Core.alert i18n.internalError, 'danger'
				# document.location.href= url.href
		this # chain

	# reload current location
	reload: (forced)->
		if forced
			document.location.replace @location
		else
			@goto @location
	# push data and change location without any further action
	pushState: (url, force)->
		url= (new URL url, Core.baseURL) unless url instanceof URL
		@location= url
		urlHref= url.href
		if force or urlHref isnt @_href
			@_href= urlHref
			history?.pushState {path:urlHref}, null, urlHref
		@_path= url.pathname
		this # chain

	# add cb when history back to prevent back and do an other action like closing pupups
	back: (cb)->
		if typeof cb is 'function'
			@_back.push cb
		else
			url= @_ctx.referrer
			if url isnt @location.href and url.startsWith Core.baseURL
				# @goto url, HISTORY_BACK
				history.back()
			else
				@goto ''
		this # chain
_newPathNode= ->
	_create null,
		$: value: []	# store dynamic params as: [paramName, node, param2, node2, ...]
# create node from path
_createNodeFromPath= (root, path, options)->
	# convert path to abs
	oPath= path= (new URL path, Core.baseURL).pathname
	# Create node
	node= root
	unless path is '/'
		# remove trailing slash
		path= path.slice 0, -1 if path.endsWith('/')
		# split
		path= path.split /(?=\/)/
		# get node
		for p in path
			if p is '/'
				throw 'Illegal path'
			# Static ignored param
			else if p.startsWith '/::'
				p= '/'+ p.substr 2
				unless n= node[p]
					n= node[p]= _newPathNode()
			# Param
			else if p.startsWith '/:'
				unless n= node['?'+p]
					n= node['?'+p]= _newPathNode()
					node.$.push p.substr(2), n
			# static
			else unless n= node[p]
				n= node[p]= _newPathNode()
			# next
			node= n
	# add node attributes
	throw "Route already set: #{oPath}" if node.once or node.in or node.alias
	_assign node, options
	return node

# lookup for URI
_lookupURI= (root, paramMather, path, params)->
	# split URL
	node= root
	unless path is '/'	# go to root
		path= path.slice 0, -1 if path.endsWith('/')
		path= path.split /(?=\/)/
		# check for index where current path is modified
		for p in path
			# check for static
			unless n= node[p]
				if paramLst= node.$	# has params [param, node, ...]
					# use params
					prmI= 0 # use matcher
					prmLen= paramLst.length
					paramValue= p.substr 1 # remove slash
					while prmI< prmLen
						paramName= paramLst[prmI]
						# has matcher
						if pMatcher= paramMather[paramName]
							# matcher
							if fx= pMatcher[1]
								# value doesn't match
								unless fx.test paramValue
									prmI += 2
									continue
							# resolver
							if fx= pMatcher[2]
								paramValue= fx paramValue
						params[paramName]= paramValue
						n= paramLst[prmI+1]	# get node
						break
				# throw not found if no node
				throw 404 unless n
			node= n
	# check node found
	if node
		node= null unless node.once or node.in or node.out or node.toggleClass
	return node
