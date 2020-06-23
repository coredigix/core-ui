###*
 * Predefined submit handlers
###

###* Send data ###
<% function _submitSendData(type){ %>(event, parts, component)->
	try
		form= this
		$form= $ form
		# Progress
		component.progress 0, Infinity
		# Send ajax
		result= await Core.post
			data: form
			url: form.action
			type: '<%-type %>'
			upload: (event)->
				component.progress event.loaded, event.total if event.lengthComputable
				return
		result= result.json()
		# Submitted event
		component.type.emit 'submitted', result
		# redirect
		if result.goto
			Core.goto result.goto
	catch err
		component.type.emit 'submit-error', err
	return
<% } %>
multipart:	<%- _submitSendData('multipart') %>
json:		<%- _submitSendData('json') %>

resize: (event, parts, component)->		component.doResizeImages component, this, 'resize', parts[1], parts[2]
resizeMax: (event, parts, component)->	component.doResizeImages component, this, 'resizeMax', parts[1], parts[2]
