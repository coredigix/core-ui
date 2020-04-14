###*
 * Ajax interface
###
get:		_xhrWrapper method: 'GET'
getJSON:	_xhrWrapper method: 'GET', reponseType: 'json'

getOnce:	_xhrWrapper method: 'GET', once: yes
getJSONOnce:_xhrWrapper method: 'GET', once: yes, reponseType: 'json'


post:		_xhrWrapper method: 'POST'
postJSON:	_xhrWrapper method: 'POST', dataType: 'json'

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
ajax: do ->
	_ajaxFx= (options)->
		throw new Error 'Ajax>> Illegal arguments' unless arguments.length is 1 and typeof options is 'object' and options
		XHR options
	### AJAX COMMONS INTERFACE ###
	_defineProperties _ajaxFx,
		# get all calls queue
		all: value: XHR_QUEUE
		# abort all
		abortAll: value: (abortMsg)->
			XHR_QUEUE.forEach (req)-> req.abort abortMsg
			this # chain
		# abort with id
		abort: value: (id, abortMsg)->
			XHR_QUEUE.forEach (req)->
				req.abort abortMsg if req.id is id
				return
			this # chain
	# return
	return _ajaxFx