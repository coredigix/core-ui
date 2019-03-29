###*
 * Response wrapper
###
class requestResponse
	constructor: (@xhr)->

	### abort current request ###
	abort : (@abortMsg)->
		@error = 'Aborted'
		@error += ": #{@abortMsg}" if @abortMsg
		@xhr.abort()
	header: (name)-> @xhr.getResponseHeader name
	### parse HTML and get MetaRedirectURL ###
	getMetaRedirectURL: ->
		if @type?.indexOf 'html' isnt -1
			if response = @xhr.responseText
				metaRegex = /<meta.+?>/gi
				while tag = metaRegex.exec response
					if /\bhttp-equiv\s*=\s*"?refresh\b/i.test tag[0]
						return tag[0].match(/url=([^\s"']+)"?/i)?[1]
		return null
# GETTERS
_defineProperties requestResponse.prototype,
	status:		get: -> @xhr.status
	statusText:	get: -> @xhr.statusText
	readyState:	get: -> @xhr.readyState
	url:		get: -> @xhr.responseURL || @originalURL
	ok:			get: -> 200 <= @xhr.status <= 299
	# content type
	type:		get: ->
		dataType = @xhr.getResponseHeader 'content-type'
		if dataType
			dataType= dataType.substr(0, dataType.indexOf ';').toLowerCase()
		dataType
	headers:	get: -> @xhr.getAllResponseHeaders()
	text:		get: -> @xhr.responseText
	json:		get: -> JSON.parse @xhr.responseText
	# BINARY RESPONSE
	response:	get: -> @xhr.response



###*
 * Browser native send request
###
_sendRequest= (options, onLoad, onError)->
	# xhr
	nativeXhr			= options.xhr or new XMLHttpRequest()
	nativeXhr.timeout	= options.timeout if options.timeout?
	# create response object
	url= options.url
	response = new requestResponse nativeXhr
	response.originalURL = url
	#response type
	nativeXhr.responseType = options.responseType if options.responseType?
	# upload / download listener
	nativeXhr.upload.addEventListener 'progress', options.upload, false if options.upload?
	# nativeXhr.upload.addEventListener 'progress', options.upload, false if options.upload?
	nativeXhr.addEventListener 'progress', options.download, false if options.download?
	# headers received
	if options.headersReceived?
		nativeXhr.addEventListener 'headersReceived',((event) => options.headersReceived event, response)
	# browser cache
	if options.cache is false
		urlParams = url.searchParams
		loop
			prm = '_' + randomString()
			unless urlParams.has prm
				urlParams.append prm, 1
				break
	# CALLBACKS
	nativeXhr.addEventListener 'load', ((event) => onLoad response), false
	nativeXhr.addEventListener 'error', ((event) => onError response), false
	nativeXhr.addEventListener 'abort', ((event) =>
		response.aborted= true
		onError response
	), false
	### PREPARE DATA ###
	options.headers ?= _create null
	dataType= options.dataType or options.header['Content-Type']
	if data= options.data
		if data instanceof FormData
			dataType= null # override type
		else if data instanceof HTMLFormElement
			data= new FormData data
			dataType= null # override type
		else unless typeof data is 'string'
			data= JSON.stringify data
			dataType= _MIME_TYPES.json
		else
			dataType= _MIME_TYPES[dataType] or dataType
	options.headers['Content-Type']= dataType if dataType
	# send request
	nativeXhr.open options.method, url.href, true
	# add headers
	for k, v of options.headers
		nativeXhr.setRequestHeader k, v
	# send data
	nativeXhr.send data or null
	# return
	return response