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
	### parse JSON ###
	json: -> JSON.parse @xhr.responseText

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
	# BINARY RESPONSE
	response:	get: -> @xhr.response


###*
 * Replace Input files in forms
###
_replace_input_file_form= (input, data)->
	nm= input.name
	data.delete nm
	for file in input[F_FILES_LIST]
		data.append nm, file, file.name
	return
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
	dataType= options.dataType or options.headers['Content-Type']
	if data= options.data
		if data instanceof FormData
			dataType= null # override type
		else if data instanceof HTMLFormElement
			frm= data
			data= new FormData data
			# check for input files
			for inp in frm.querySelectorAll 'input[type="file"]'
				if inp[F_FILES_LIST]
					_replace_input_file_form inp, data
				# remove empty files
				else unless inp.files.length
					data.delete inp.name
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