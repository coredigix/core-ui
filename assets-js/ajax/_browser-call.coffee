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
 * Convert formData to JSON
###
_convertFormDataToJSON= (formData)->
	result= _create null
	formData.forEach (v,k)->
		if typeof v is 'string'
			# if sub path
			k= k.split '.'
			len= k.length - 1
			i=0
			res= result
			while i < len
				res= res[k[i++]]?= _create null
			# set value
			k= k[len]
			if res[k]
				res[k]= [res[k]] unless Array.isArray res[k]
				res[k].push v
			else
				res[k]= v
		return
	return JSON.stringify result

###*
 * Convert formData to URL encoded
###
_convertFormDataToUrlEncoded= (formData)->
	params = new URLSearchParams()
	formData.forEach (v,k)->
		params.append k, v if typeof v is 'string'
		return
	return params.toString()

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
	# decode mimetype
	dataType= _MIME_TYPES[dataType] or dataType
	# encode data
	if data= options.data
		# string
		if typeof data is 'string'
			dataType ?= 'text/plain'
		# form
		else if data instanceof FormData or data instanceof HTMLFormElement
			# create form data
			unless data instanceof FormData
				frm= data
				data= new FormData data
				# check for input files
				for inp in frm.querySelectorAll 'input[type="file"]'
					if inp[F_FILES_LIST]
						_replace_input_file_form inp, data
					# remove empty files
					else unless inp.files.length
						data.delete inp.name
			# encode
			if dataType is _MIME_TYPES.json
				data= _convertFormDataToJSON data
			else if dataType is _MIME_TYPES.urlencoded
				data= _convertFormDataToUrlEncoded data
			else if dataType and dataType isnt _MIME_TYPES.multipart
				throw new Error 'Could not convert FormData to: ' + dataType
		# Object
		else if not dataType or dataType is _MIME_TYPES.json
			data= JSON.stringify data
			dataType= _MIME_TYPES.json
		else
			throw new Error "Illagal data for mimetype: " + dataType
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