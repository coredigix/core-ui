###*
 * Predefined submit methods
###

###* Send data ###
urlencoded:	(event, parts)-> @_sendFormData 'urlencoded', event, parts
multipart:	(event, parts)-> @_sendFormData 'multipart', event, parts
json:		(event, parts)-> @_sendFormData 'json', event, parts
off:		(event, parts)-> # Disable submit
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
		if msg= result.message
			await Core.alert msg
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