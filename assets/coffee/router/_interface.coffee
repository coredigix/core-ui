###*
 * Default goto
###
goto: DEFAULT_GOTO_FX

###*
 * ROUTER
 * @optional @param {Boolean} options.caseSensitive - if path is case sensitive @default false
 * @optional @param {Boolean} options.ignoreTrailingSlash - ignore trailing slash @default true
 * @optional @param {Number} options.cacheMax - cache max entries @default 50
 * @optional @param {Number} options.maxLoops - Lookup max loop to prevent infinit loops @default 1000
 * @optional @param {function} options.out - called when quiting page
 * @optional @param {function} options.catch - called when error happend: Example: {code:404}
###
Router: do ->
	###*
	 * DEFAULT OPTIONS
	###
	DEFAULT_OPTIONS=
		caseSensitive:			no
		ignoreTrailingSlash:	yes
		maxLoops:				1000
		cacheMax:				50
		out: (url, isForced)->	# called when leaving the page
			document.location.replace url
			return
		catch: (err, ctx)->		# Catch goto errors. Example: {code: 404}
			CORE.fatalError 'ROUTER', err
			return
	ROUTER_ROOT_PATH=	-1	# Is document root path (Document real path)
	HISTORY_NO_STATE=	0	# do not insert state in history, use when calling history.back()
	HISTORY_REPLACE=	1	# do replace in history instead of adding
	HISTORY_BACK=		2	# prevent history push when back
	ROUTER_RELOAD=		3	# Reload path
	# ROUTES
	ROUTE_ILLEGAL_PATH_REGEX= /[#]|[^\/]\?/
	###* Create route node ###
	_createRouteNode= ->
		get:		null
		wrappers:	null
		# index
		static:		{}
		params:		null
		wildcards:	null
		wildcard:	null
		# metadata
		param:		null
		route:		null
		path:		null
	###* Resolve or create node inside array ###
	_resolveNodeInArray= (part, paramMap, arr, upsert)->
		paramName= part.slice 1
		throw "Please use \"Router.param(...)\" method to define parameter: #{paramName}" unless _has paramMap, paramName
		paramRegex= paramMap[paramName][0]
		len= arr.length
		i= 0
		while i<len
			return arr[i+2] if arr[i+1] is paramName
			i+= 3
		if upsert
			node= do _createRouteNode
			node.param= paramName
			arr.push paramRegex, paramName, node
		return node
	###*
	 * TREE
	 * NODE:
	 * 		├─ get ---
	 * 		├─ wrappers: [wrapper1, ...]
	 * 		├─ static
	 * 		│	├─ node1: NODE
	 * 		│	└─ node2: NODE
	 * 		├─ params: [/regex/, NODE, ...]
	 * 		├─ wildCards: [/regex/, NODE, ...]
	 * 		└─ wildcard: NODE
	###
	PARAM_DEFAULT_REGEX= test: -> true
	PARAM_DEFAULT_CONVERTER= (data)-> data
	###*
	 * ROUTER
	###
	ID_GEN= 0 # Generate unique id for each create router
	class Router
		constructor: (options)->
			# Options
			@_options= _assign {}, DEFAULT_OPTIONS, options
			# PARAMS
			@_params= {}
			# Router tree
			@_tree= _createRouteNode()
			@_tree.static['']= @_tree
			# metadata
			@_node= null # current node
			# URL
			@referrer= @location= if document.referrer then new URL document.referrer else null
			# Router id, used when calling ajax
			@id= 'rtr-' + (ID_GEN++) # Router id
			# Cache
			@_cache= new Core.LRU_TTL(max: @_options.cacheMax)
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
					path= event.state?.path or document.location.href
					if typeof path is 'string'
						@goto path, HISTORY_BACK
				return
			window.addEventListener 'popstate', _popstateListener, off
			# start router
			$ => @goto document.location.href, ROUTER_ROOT_PATH
			return

		###*
		 * Add param
		 * @param {String, Array[String]} paramName - Name of the path or query parameter
		 * @optional @param {RegExp, Function} regex - Check the param value
		 * @optional @param {Function} convert - convert param value (async)
		###
		param: (paramName, regex, convert)->
			try
				# Check param name
				if _isStrArray paramName
					@param(el, regex, convert) for el in paramName
					return this # chain
				else
					throw 'Illegal param name'
				throw "Param '#{paramName}' already set" if @$[paramName]
				# Prepare arguments
				if typeof regex is 'function'
					regex= test: regex
				else if regex?
					throw 'Invalid 2nd arg' unless regex instanceof RegExp
				else regex= PARAM_DEFAULT_REGEX
				# convert
				if convert?
					throw 'Invalid 3rd arg' unless typeof convert is 'function'
				else convert= PARAM_DEFAULT_CONVERTER
				# Add
				@_params[paramName]=
					regex: regex
					convert: convert
			catch err
				err= new Error "ROUTER.param>> #{err}" if typeof err is 'string'
				throw err
			this # chain
		###*
		 * Wrap route
		###
		wrap: (route, wrapper)->
			throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof route is 'string' and typeof wrapper is 'function'
			(@_loadRoute(route).wrappers?= []).push wrapper
			this # chain
		###*
		 * GET
		###
		get: (route, node)->
			throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof route is 'string' and typeof node is 'object' and node
			routeObj= @_loadRoute(route)
			throw new Error "Route already set: #{route}" if routeObj.get?
			node.route?= route
			routeObj.get= node
			this # chain
		###*
		 * Goto
		###
		goto: (path, doState)->
			try
				# convert URL
				url= (new URL url, Core.baseURL) unless url instanceof URL
				# previous
				previousNode= @_node
				if previousLocation= @location
					previousPath= previousLocation.pathname
					@referrer= previousLocation
				# create context
				path=		url.pathname
				@location=	url
				ctx=
					isRoot:			doState is ROUTER_ROOT_PATH
					url:			url
					path:			path
					isHistoryBack:	doState is HISTORY_BACK # if this is fired by history.back
					isNew:			(doState is ROUTER_ROOT_PATH) or (doState is ROUTER_RELOAD) or (path isnt previousPath)
					params:			{}	# Path params
					query:			{}	# Query params
					history:		path: url.href
					route:			null
					options:		null
					# referrer
					referrer:		@referrer
					referrerOptions: previousNode.node
				# lookup for new Node
				unless result= @_cache.get path
					result= @_resolvePath path
					@_cache.set path, result
				@_node= result
				throw result.error or {code: result.status} unless result.status is 200
				ctx.options= result.node
				ctx.route= result.route
				# Path params
				params= ctx.params
				paramMap= @_params
				i=2
				len= resp.length
				while i < len
					pName= resp[i++]
					params[pName]= await paramMap[pName].convert resp[i++]
				# Query params
				params= ctx.query
				url.searchParams.forEach (v, k)->
					# convert value
					v= await p.convert(v) if p= paramMap[k]
					# add
					if v2= params[k]
						if _isArray v2 then v2.push v
						else params[k]= [v2, v]
					else params[k]= v
				# call previous node out
				if previousNode and (previousNodeOptions= previousNode.node)
					await previousNodeOptions.out? ctx
					await previousNodeOptions.outOnce? ctx if ctx.isNew
				# push in history
				urlHref= url.href
				if doState is ROUTER_ROOT_PATH
					history?.pushState (path:urlHref), '', urlHref
				else unless (doState is HISTORY_BACK) or (previousLocation and urlHref is previousLocation.href) # do not push if it's history back or same URL
					historyState= path: urlHref
					if doState is HISTORY_REPLACE
						history?.replaceState historyState, '', urlHref
					else unless doState is HISTORY_NO_STATE
						history?.pushState historyState, '', urlHref
				# call listeners
				if (wrappers= result.wrappers) and wrappers.length
					wrapperI= 0
					wrapperNext= =>
						if wrapperI < wrappers.length
							return wrappers[wrapperI++] ctx, wrapperNext
						else
							return @_gotoRun result, ctx
					await wrapperNext()
				else
					await _gotoRun result, ctx
			catch err
				err= "ROUTER.goto>> #{err}" if typeof err is 'string'
				@_options.catch err, ctx
			this # chain
		_gotoRun: (result, ctx)->
			node= result.node
			if ctx.isNew
				# abort active xhr calls
				Core.ajax.abort router.id
				# toggle <html> classes
				$html= $('html')
				$html.removeClass referrerOptions.toggleClass if (referrerOptions= ctx.referrerOptions) && referrerOptions.toggleClass
				$html.addClass node.toggleClass if node.toggleClass
				# Goto top
				scrollTo 0, 0 if node.scrollTop
				# Call current node in once
				await node.once? ctx
			# Call in
			await node.in? ctx
			return
		###*
		 * Reload
		###
		reload: (forced)->
			if forced
				@_options.out @location, true
			else
				@goto @location, ROUTER_RELOAD
			this # chain
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
		###*
		 * Load route
		###
		_loadRoute: (route)->
			throw "Illegal path: #{path}" if ROUTE_ILLEGAL_PATH_REGEX.test(route)
			settings= @_options
			path= route
			path= path.toLowerCase() unless settings.caseSensitive
			parts= path.split '/'
			partsLen= parts.length
			paramSet= new Set() # check params are not repeated
			paramMap= @_params
			# Settings
			avoidTrailingSlash= not settings.ignoreTrailingSlash
			# metadata
			nodePath= []
			# Go through tree
			currentNode= @_tree
			for part,i in parts
				# wild card
				if part is '*'
					throw "Illegal use of wildcard: #{route}" unless i+1 is partsLen
					node= currentNode.wildcard ?= do _createRouteNode
					node.param= '*'
					node.type= ROUTER_WILDCARD_NODE
				#  parametered wildcard
				else if part.startsWith '*'
					throw "Illegal use of wildcard: #{route}" unless i+1 is partsLen
					currentNode.wildcards?= []
					node= _resolveNodeInArray part, paramMap, currentNode.wildcards, yes
					node.type= ROUTER_WILDCARD_PARAM_NODE
				# parametred node
				else if part.startsWith ':'
					currentNode.params?= []
					node= _resolveNodeInArray part, paramMap, currentNode.params, yes
					node.type= ROUTER_PARAM_NODE
				# static node
				else
					part= part.slice(1) if part.startsWith('?') # escaped static part
					node= currentNode.static[part] ?= do _createRouteNode
					node.type= ROUTER_STATIC_NODE
				# Check params not repeated
				if vl= node.param
					throw "Repeated param [#{vl}] in route: #{path}" if paramSet.has vl
					paramSet.add vl
				# Avoid trailing slash and multiple slashes
				node.static['']= node if avoidTrailingSlash # Avoid trailing slash and multiple slashes
				# stack
				nodePath.push node
				unless node.path
					node.path?= nodePath.slice(0)
					node.route= parts.slice(0, i+1).join('/')
				# next
				currentNode= node
			return currentNode
		###*
		 * Resolve path
		 * @return {Object} {status, node, wrappers:[], error, params:[] }
		###
		_resolvePath: (path)->
			try
				currentNode= @_tree
				paramMap= @_params
				settings= @_options
				path= path.toLowerCase() unless settings.caseSensitive
				# Result
				result=
					status:		404
					node:		null
					wrappers:	[]
					error:		null
					params:		[]
				# Non recursive alg
				parts= path.split '/'
				partsLen= parts.length
				maxLoops= settings.maxLoops
				maxLoopsI= 0 # Inc is faster than dec
				nodeStack= [currentNode]
				metadataStack= [0, 0, 0] # [NodeType(0:static)]
				while nodeStack.length
					# prevent server freez
					throw new Error "Router>> Seeking exceeds #{maxLoops}" if ++maxLoopsI > maxLoops
					# Load ata
					currentNode= nodeStack.pop()
					# metadata
					dept=		metadataStack.pop()
					nodeType=	metadataStack.pop()
					nodeIndex=	metadataStack.pop()
					# path part
					part= parts[dept]
					# switch nodetype
					switch nodeType
						when ROUTER_STATIC_NODE # Static
							# add alts
							if currentNode.wildcard
								nodeStack.push currentNode
								metadataStack.push 0, ROUTER_WILDCARD_NODE, dept
							if currentNode.wildcards
								nodeStack.push currentNode
								metadataStack.push 0, ROUTER_WILDCARD_PARAM_NODE, dept
							if currentNode.params
								nodeStack.push currentNode
								metadataStack.push 0, ROUTER_PARAM_NODE, dept
							# check for static node
							if node= currentNode.static[part]
								currentNode= node
								++dept
								if dept < partsLen
									nodeStack.push currentNode
									metadataStack.push 0, ROUTER_STATIC_NODE, dept
						when ROUTER_PARAM_NODE # path param
							params= currentNode.params
							len= params.length
							while nodeIndex<len
								if params[nodeIndex].test part
									# save current index
									nodeStack.push currentNode
									metadataStack.push (nodeIndex+3), ROUTER_PARAM_NODE, dept
									# go to sub route
									currentNode= params[nodeIndex+2]
									++dept
									if dept < partsLen
										nodeStack.push currentNode
										metadataStack.push nodeIndex, ROUTER_STATIC_NODE, dept
									break
								nodeIndex+= 3
						when ROUTER_WILDCARD_PARAM_NODE # wildcard param
							params= currentNode.wildcards
							len= params.length
							pathEnd= parts.slice(dept).join('/')
							while nodeIndex<len
								if params[nodeIndex].test pathEnd
									# go to sub route
									currentNode= params[nodeIndex+2]
									dept= partsLen
									break
								nodeIndex+= 3
						when ROUTER_WILDCARD_NODE # wildcard
							currentNode= currentNode.wildcard
							dept= partsLen
						else
							throw "Unexpected error: Illegal nodeType #{nodeType}"
					# Check if found
					if (dept is partsLen) and (nodeH= currentNode.get)
						result.status= 200
						result.node= currentNode
						# Load wrappers and error handlers
						wrappers= result.wrappers
						# errHandlers= result.errorHandlers
						paramArr= result.params
						j=-1
						for node in currentNode.path
							# wrappers
							if arr= node.wrappers
								wrappers.push el for el in arr
							# # error handlers
							# if arr= node.onError
							# 	errHandlers.push el for el in arr
							# params
							switch node.type
								when ROUTER_PARAM_NODE
									paramArr.push node.param, parts[j]
								when ROUTER_WILDCARD_PARAM_NODE, ROUTER_WILDCARD_NODE
									paramArr.push node.param, parts.slice(j).join('/')
							# next
							++j
						break
			catch err
				err= new Error "ROUTER>> #{err}" if typeof err is 'string'
				result.status= 500
				result.error= err
			return result
	# return
	return Router