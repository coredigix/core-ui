###*
 * Router
###

Router = ->
	throw new Error 'Required new' unless new.target
	@_q= [] # queue
	@_currentPath= null # current route
	# onload
	$ =>
		_routerGoto this,
			path: document.location.pathname
			isRoot: yes
			isBack: no
			referrer: document.referrer
			srcElement: null
		return
	return

_defineProperties Router.prototype,
	# add new call
	on: value: (options)->
		try
			throw 'Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
			# check path
			if typeof options.path is 'string'
				options.path= do (path= options.path)-> test: (p)-> p is path
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
		else if typeof options isnt 'string'
			throw new Error 'Illegal options'
		# href
		path= options.path
		throw new Error 'Expected string path' unless typeof path is 'string'
		return if path is @_currentPath # do nothing if the same page

		options.referrer= @_currentPath
		# push in history
		#TODO
		# call
		_routerGoto this, options
		return this
# goto
_routerGoto= (router, options)->
	# quit current route
	if router._currentPath
		_routerSelectPath options, router._currentPath, router._q, false
	# go in new route
	router._currentPath= options.path
	_routerSelectPath options, options.path, router._q, true
	return

_routerSelectPath= (options, path, queue, isSelect)->
	i=0
	len= queue.length
	$html= $('html')
	while i < len
		# extract info
		regex= queue[i++]
		toggleClass= queue[i++]
		cbIn= queue[i++]
		cbOut= queue[i++]
		# check regex
		if regex.test path
			# toggle class
			$html.toggleClass toggleClass, isSelect if toggleClass
			# call cb
			cb= if isSelect then cbIn else cbOut
			try
				cb options
			catch err
				core.fatalError 'Router', 'Uncaugth error', err
	return
