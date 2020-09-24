###*
 * Predefined submit methods
###

###* Send data ###
urlencoded:	(event, parts)-> @_sendFormData 'urlencoded', event, parts
multipart:	(event, parts)-> @_sendFormData 'multipart', event, parts
json:		(event, parts)-> @_sendFormData 'json', event, parts
off:		(event, parts)-> # Disable submit
GET:		(event, parts)->
	form= event.target
	url= new URL form.action, document.location.href
	url.search= ''
	params= url.searchParams
	(new FormData form).forEach (v,k)->
		params.append k, v if typeof v is 'string'
		return
	Core.defaultRouter.goto url
	return
_sendFormData: (type, event, parts)->
	try
		form= event.target
		$form= $ form
		# Progress
		$progress= $form.find('.progress:first')
		$progressTrack= $progress.find('.track:first')
		$progressLabel= $progress.find('.label:first')
		# Send ajax
		result= await Core.post
			data: form
			url: form.action
			type: type
			upload: (event)=>
				$progress.removeClass 'loading'
				if event.lengthComputable
					prcent= (event.loaded / event.total)>>0
					$progressTrack.css 'width', "#{prcent}%"
					$progressLabel.text "#{prcent}%"
				return
		result= result.json()
		# Show message
		if msg= result.message
			await Core.alert msg
		# Show ERROR message
		if msg= result.error
			await Core.alert {text: msg, state: 'danger'}
		# Show modal view
		if msg= result.modal
			res= await Core.modal Components[msg]? result
			return if res is 'ok'
		# redirect
		if result.goto
			return Core.goto result.goto
		else if result.redirect
			document.location= result.redirect
	catch err
		@emit 'form-error', err
	return


###* Before submit files ###
resize: (element, parts)->		@doResizeImages element, 'resize', parts[1], parts[2]
resizeMax: (element, parts)->	@doResizeImages element, 'resizeMax', parts[1], parts[2]
