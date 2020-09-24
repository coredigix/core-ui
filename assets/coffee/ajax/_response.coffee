###*
 * Response
###
class requestResponse
	constructor: (@xhr)->
		@error= null
		return

	### abort current request ###
	abort : (@abortMsg)->
		@error = 'Aborted'
		@error += ": #{@abortMsg}" if @abortMsg
		@xhr.abort()
		this # chain
	header: (name)-> @xhr.getResponseHeader name
	###*
	 * parse HTML and get MetaRedirectURL
	###
	getMetaRedirectURL: ->
		if @type?.indexOf 'html' isnt -1
			if response = @xhr.responseText
				metaRegex = /<meta.+?>/gi
				while tag = metaRegex.exec response
					if /\bhttp-equiv\s*=\s*"?refresh\b/i.test tag[0]
						return tag[0].match(/url=([^\s"']+)"?/i)?[1]
		return null
	### parse JSON ###
	json: -> if data= @xhr.responseText then JSON.parse data else null

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
