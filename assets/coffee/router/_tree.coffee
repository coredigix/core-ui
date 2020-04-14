###*
 * Router tree
 * @param {Boolean} options.caseSensitive - if path is case sensitive @default false
 * @param {Boolean} options.ignoreTrailingSlash - ignore trailing slash @default true
 * @param {Number} options.cacheMax - cache max entries @default 100
 *
 * Each route node contains
 * 		- subNodeesNames: subNode
 * 		- '/p'	:[paramName]	# list of params
 * 		- '/pR'	:[paramMatcher]	# list of param matchers
 * 		- '/*'	:[paramName]	# list of wildcard params
 * 		- '/*R'	:[paramName]	# list of wildcard param matchers
 * 		- '/w'	:[paramName]	# wrappers
 * 		- '/route': # This node route
###
_RouterTreeEmptyMatcher= test: -> true
class RouterTree
	constructor: (options)->
		@c= !!options.caseSensitive
		@s= options.ignoreTrailingSlash isnt false
		# cache max length
		if mx= options.cacheMax
			throw new Error "cacheMax expected > 0" unless typeof mx is 'number' and mx > 0
		else
			mx= 100
		@cacheMax= mx
		# Params
		@$= _create null, '*': value: []
		# Routes
		@r= _create null
		# static routes
		@st= _create null
		# Root route
		@['/']= @r['/']= @st['/']= _create null,
			'/route': value: '/'
			'/w': value: []	# wrappers
		# path cache
		@ch= _create null
		@_tme= null	# cache timeout
		return

	###*
	 * Add param
	###
	param: (options)->
		paramName= options.name
		throw new Error 'Expected paramName' unless typeof paramName is 'string'
		throw new Error "Param '#{paramName}' already set" if @$[paramName]
		# check options
		if matches= options.matches
			throw new Error 'Illegal matches' unless typeof matches.test is 'function'
		if resolver= options.resolver
			throw new Error 'Resolver expected function' unless typeof resolver is 'function'
		matches ?= _RouterTreeEmptyMatcher
		@$[paramName]= [matches, resolver]
		this # chain
	###*
	 * Resolve params
	 * @return {Promise}
	###
	resolveParams: (map)->
		paramMap= @$
		for k,v of map
			if r= paramMap[k]?[1]
				if Array.isArray v
					for v2,i in v
						v[i]= await r v2
				else
					map[k]= await r v
		return
	###*
	 * Add route
	###
	add: (route)->
		throw new Error 'Illegal argument' unless arguments.length is 1 and typeof route is 'string'
		# operations on route
		route= route.trim()
		# route= route.toLowerCase() unless @c
		if (route isnt '/') and @c and route.endsWith '/'
			route= route.slice(0, -1)
		# return route if already set
		unless currentNode= @r[route]
			currentNode= @['/']
			allNodes= @r
			currentPath= []
			# split
			route= route.substr(1) if route.startsWith '/'
			routeParts= route.split '/'
			# Prevent double params
			paramSet = new Set()
			# Loop
			for part, i in routeParts
				part= part.toLowerCase() unless @c or part.startsWith ':'
				currentPath.push part
				# is param
				if isParam= part.startsWith(':') or part.startsWith('*')
					part= '?'+part
				# escaped
				else if part.startsWith '?'
					part= part.substr 1
				# create sub node
				unless node= currentNode[part]
					# create node
					currentRoute= '/'+currentPath.join('/')
					node= currentNode[part]= _create null,
						'/w': value: currentNode['/w'].slice(0)	# wrappers
						'/route': value: currentRoute
					allNodes[currentRoute]= node
					# params
					if isParam
						# if it's a param
						if part.startsWith '?:'
							paramName= part.substr(2)
							paramType= '/p'
						# whild card
						else
							throw new Error "Wildcard must be the last param in route: #{route}" unless i is (routeParts.length - 1)
							paramType= '/*'
							if part is '?*'
								paramName= '*'
							else
								paramName= part.substr(2)
						# PUSH
						throw new Error 'Could not use "__proto__" as param name' if paramName is '__proto__'
						throw new Error "Route contains duplicated param '#{paramName}': #{route}" if paramSet.has paramName
						throw new Error "Unknown param '#{paramName}'. Add it via 'param' method" unless paramOp= @$[paramName]
						paramSet.add paramName
						(currentNode[paramType] ?= []).push paramName
						(currentNode[paramType+'R'] ?= []).push paramOp[0]
				# next
				currentNode= node
		# add if static
		unless route.match /\/[:*]/
			@st[route.replace(/\/\?/g, '/')]= currentNode
		return currentNode
	###*
	 * Get route
	###
	get: (route)->
		throw new Error 'Illegal argument' unless arguments.length is 1 and typeof route is 'string'
		# operations on route
		route= route.trim()
		route= route.toLowerCase() unless @c
		if (route isnt '/') and @c and route.endsWith '/'
			route= route.slice(0, -1)
		# resp
		return @r[route]
	###*
	 * Has route
	###
	has: (route)-> !!@get route
	###*
	 * Go trough all subroutes
	###
	seek: (route, cb)->
		throw new Error "Expected two arguments" unless arguments.length is 2
		throw new Error "Second arg expected function" unless typeof cb is 'function'
		if currentNode= @r[route]
			seekQueue= [currentNode]
			i= 0
			maxSize= Object.keys(@r).length
			while i < seekQueue.length
				currentNode= seekQueue[i++]
				return if cb(currentNode) is false
				# add subroutes
				for k of currentNode
					seekQueue.push currentNode[k] unless k.startsWith '/'
				# security
				throw new Error "Route tree has enexpected nodes" if i > maxSize
			return true # route found
		else
			return false # route not found
	###*
	 * Add wrapper
	###
	wrap: (route, wrapperFx)->
		@seek route, (node)->
			node['/w'].push wrapperFx
			return
		this # chain
	###*
	 * Resolve path
	###
	resolve: (path)->
		cacheQ= @ch
		isCacheAdded= no
		if path is '/'
			unless result= cacheQ['/']
				node= @['/']
				result= cacheQ['/']= [1, node, node['/w']]
				isCacheAdded= true
		else
			# fix path
			path= path.trim()
			path= path.toLowerCase() unless @c
			if @c and path.endsWith '/'
				path= path.slice(0, -1)
			# resolve from static paths
			unless result= @ch[path]
				if node= @st[path]	# static route
					result= [1, node, node['/w']]
				else # resolve dynamic route
					result= @_resolve path
				# put in cache
				@ch[path]= result
				# up cache
				isCacheAdded= yes
		# Up
		++result[0]
		# clean cache
		if isCacheAdded
			@cleanCache()
		return result
	###*
	 * cleanCache
	###
	cleanCache: ->
		clearTimeout @_tme if @_tme
		@_tme= setTimeout (=> _routerTreeCleanCache this), 0
		return
	###*
	 * Force path resolve
	###
	_resolve: (path)->
		parts = path.split '/'
		currentNode= @['/']
		result= [1, currentNode]
		for part, level in parts
			# Ignore empty parts
			continue unless part
			# check static part
			if node= currentNode[part]
				# static matched
			# check params
			else if pathParamsResolvers= currentNode['/pR']
				for r, ri in pathParamsResolvers
					if r.test part
						param= currentNode['/p'][ri] 
						node= currentNode['?:'+param]
						result.push param, part
						break
			# check whild card params
			else if pathParamsResolvers= currentNode['/*R']
				part= parts.slice(level).join('/')
				for r, ri in pathParamsResolvers
					if r.test part
						param= currentNode['/*'][ri]
						node= currentNode['?*'+param]
						result.push param, part
						break
			# next
			if node
				currentNode= node
			else
				throw {code: 404, route: currentNode['/route'], path: path}
		result[1]= currentNode
		return result


###*
 * Clear cache
###
_routerTreeCleanCache= (router)->
	cacheQ= router.ch
	kies= _keys cacheQ
	if kies.length > router.cacheMax
		mx= router.cacheMax
		loop
			c= 0
			minus= 1
			smallest= Infinity
			for k,v of cacheQ
				# minus
				vl= (v[0] -= minus)
				# remove from cache
				if vl <= 0
					delete cacheQ[k]
				else
					++c
					smallest= vl if vl < smallest
			break if c < mx
			minus= smallest
	return

