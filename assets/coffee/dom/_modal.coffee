###*
 * Show modals
 * TODO
###
# modal: (modalName, options)->
# 	html= Components._ modalName, options
# 	return modal
#TODO

modal: (htmlFactory, options)->
	# Create promise
	_close= null
	_body= null
	p= new Promise (res, rej)->
		# close Fx
		_close= -> res 'close'
		# DOM
		body= document.body
		body.classList.add 'modal-open'
		# Render
		_body= _toHTMLElement htmlFactory options
		body.appendChild _body
		# Promise
		_click= (event)->
			if btn= @closest('[d-value]')
				res btn.getAttribute 'd-value'
			else unless @closest '.mini-container'
				res 'close'
			return
		_body.addEventListener 'click', _click, false
		return
	# Add finnaly
	p= p.finally (res)->
		body= document.body
		body.removeChild _body if _body?
		body.classList.remove 'modal-open' unless body.querySelector ':scope>.modal'
		return res
	# Add APIs
	p.body= _body
	p.close= _close
	# Return
	return p
	
	
alert: (message)->
	if typeof message is 'string' then opt= text: message
	else if message? then opt= message
	else throw new Error "Illegal arguments"
	opt.ok ?= i18n.ok or 'ok'
	@modal Core.html.alert, opt
confirm: (message)->
	if typeof message is 'string' then opt= text: message
	else if message? then opt= message
	else throw new Error "Illegal arguments"
	opt.ok ?= i18n.ok or 'ok'
	opt.cancel ?= i18n.cancel or 'Cancel'
	@modal Core.html.confirm, opt
