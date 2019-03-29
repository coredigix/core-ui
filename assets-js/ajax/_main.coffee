###*
 * Promise based ajax
###
#=include _mime-types.coffee
#=include _browser-call.coffee
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
						throw resp.error unless response.ok
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

###
 * INTERFACE
 * Core.get('url').then(...)
 * Core.get options
 * Core.ajax
 * 		method: 'GET, POST, ...'
 * 		url: 'url'
 * 		once: true		# execute this once, and use a cache for it
 * 		onceTimeout: 0	# when "once" is set: cache timeout: 0 meanse remove immdediate, false disable remove
 * 		timeout: 125254 # timeout in ms
 * 		delay: 0		# time to wait before sending this request
 * 		id: 'str'		# string id for this call (used to controlle it from other code)
 * 		headers: 		# http headers to send
 *   		accepts: ''
 *   	cache: true		# disable browser cache
 *
 * 		# POST
 * 		data: Object, Form, FormData, String		# data to send
 * 		
 * 		# RESPONSE PARSING
 * 		reponseType: "json"	# parse response data as JSON
 * 		dataType: "json"	# serialize data as JSON
 *   		
 *   	# PROGRESS AND CALLBACKS
 *   	upload:	 (event)->
 *   	download: (event)->
 *   	headersReceived: (event, response)->	# called when headers received, can abort if not of desired type as example
 *
###
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
		
_defineProperties Core,
	ajax:		 value: (options)->
		throw new Error 'Ajax>> Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
		XHR options
	get:		value: _xhrWrapper method: 'GET'

	post:		value: _xhrWrapper method: 'POST'
	# custom resp
	getJSON:	value: _xhrWrapper method: 'GET', reponseType: 'json'
	# getXML:
	# get once
	getOnce:	value: _xhrWrapper method: 'GET', once: yes
	getJSONOnce:value: _xhrWrapper method: 'GET', once: yes, reponseType: 'json'
	#POST
	postJSON:	value: _xhrWrapper method: 'POST', dataType: 'json'


### AJAX COMMONS INTERFACE ###
_defineProperties Core.ajax,
	# get all calls queue
	all: value: XHR_QUEUE
	# abort all
	abortAll: value: (abortMsg)->
		XHR_QUEUE.forEach (req)-> req.abort abortMsg
		this # chain