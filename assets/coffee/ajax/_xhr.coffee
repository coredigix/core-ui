###*
 * XHR
###
XHR_QUEUE= new Set() # store all ajax calls
XHR= (options)->
	# create promise
	resolve= null
	reject= null
	pFinal= p= new Promise (res, rej)->
		resolve= res
		reject= rej
		return
	# method
	options.method ?= 'GET'
	# other operations
	resp= null
	try
		# check options
		url= options.url
		throw 'URL required' unless url
		options.url= new URL url, Core.baseURL
		# request headers
		if options.headers
			headers= _create null
			for k,v of options.headers
				headers[_capitalizeSnakeCase k]= v

		# parse return value
		if vl= options.reponseType
			throw '"responseType" expected string' unless typeof vl is 'string'
			vl= vl.toLowerCase()
			vl= _MIME_TYPES[vl] or vl
			switch vl
				when 'application/json'
					pFinal= p.then (resp)->
						throw resp.error unless resp.ok
						resp.json()
				when 'text/plain'
					break
				else
					throw 'Illegal value for "responseType"'
		# XHR
		resp= _sendRequest options, resolve, reject
	catch err
		err= new Error "AJAX>> #{err}" if typeof err is 'string'
		reject err
	# INTERFACE
	_defineProperties pFinal,
		abort:		value: (errMsg)-> resp.abort errMsg
		id:			value: options.id
		resolve:	value: (vl)->
			resolve vl
			@abort()
			return
		reject:		value: (vl)->
			reject vl
			@abort()
			return
	# store this call
	XHR_QUEUE.add pFinal
	pFinal.finally -> XHR_QUEUE.delete pFinal
	# return Promise
	return pFinal

# WRAPPER
_xhrWrapper= (options2)->
	(url, options)->
		try
			throw 'Illegal arguments' unless arguments.length in [1, 2]
			options ?= _create null
			if typeof url is 'string'
				options.url= url
				_assign options, options2
			else
				_assign options, url, options2
			XHR options
		catch err
			err= "AJAX #{options2.method}>> #{err}" if typeof err is 'string'
			throw err
