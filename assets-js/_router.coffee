###*
 * Router
###

Router = ->
	throw new Error 'Required new' unless new.target
	@_q= [] # queue
	@_currentPath= null # current route
	# onload
	$ =>
		l= document.location
		_routerGoto this,
			path: l.pathname.replace(/\/$/, '') + l.hash
			isRoot: yes
			isBack: no
			referrer: document.referrer
			srcElement: null
		# add onpopstate
		_popstateListener= (event)=>
			state= event.state
			if typeof state?.path is 'string'
				_routerGoto this, state
			return
		window.addEventListener 'popstate', _popstateListener, off
		return
	return

_defineProperties Router.prototype,
	# add new call
	on: value: (options)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
			# check path
			if typeof options.path is 'string'
				# fix path
				u= new URL options.path, Core.baseURL
				u= u.pathname.replace(/\/$/, '') + u.hash
				options.path= do (path= u)-> exec: (p)-> p is path
			else unless options.path instanceof RegExp
				throw 'Options.path expected String or RegExp'
			# check arguments
			throw 'Options.toggleClass expected string' if options.toggleClass and typeof options.toggleClass isnt 'string'
			throw 'Options.in expected function' if options.in and typeof options.in isnt 'function'
			throw 'Options.out expected function' if options.out and typeof options.out isnt 'function'
			# add
			@_q.push options.path, options.toggleClass, options.in, options.out
		catch err
			if typeof err is 'string'
				err= "Router::on>>" + err
			throw err
		return this

	# remove a regex: #TODO
	# Router.off= (regex)->

	# call a route
	goto: value: (options)->
		throw new Error 'Illegal arguments' unless arguments.length is 1
		if typeof options is 'string'
			options= path: options
		else unless typeof options?.path is 'string'
			throw new Error 'Illegal options'
		# href
		path= options.path
		throw new Error 'Expected string path' unless typeof path is 'string'
		return if path is @_currentPath # do nothing if the same page

		options.referrer= @_currentPath
		# push in history
		history.pushState? options, "", path
		# call
		return _routerGoto this, options
# goto
_routerGoto= (router, options)->
	# set title
	document.title= options.title if options.title
	# quit current route
	if router._currentPath
		_routerSelectPath options, router._currentPath, router._q, false
	# go in new route
	router._currentPath= options.path
	return _routerSelectPath options, options.path, router._q, true

_routerSelectPath= (options, path, queue, isSelect)->
	i=0
	len= queue.length
	$html= $('html')
	found= false
	while i < len
		# extract info
		regex= queue[i++]
		toggleClass= queue[i++]
		cbIn= queue[i++]
		cbOut= queue[i++]
		# check regex
		if params= regex.exec path
			found= true
			# toggle class
			$html.toggleClass toggleClass, isSelect if toggleClass
			# call cb
			cb= if isSelect then cbIn else cbOut
			if typeof cb is 'function'
				try
					cb options, params
				catch err
					Core.fatalError 'Router', 'Uncaugth error', err
	return found
