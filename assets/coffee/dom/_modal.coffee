###*
 * Show modals
 * @param {String} html - HTML modal
 * @return {Object} Model object
###
# modal: (html)->
# 	html= Components._ modalName, options
# 	return modal
#TODO

modal: (html)->
	# Create promise
	_close= null
	element= null
	# return promise
	p= new Promise (res, rej)->
		# close Fx
		_close= ->
			res 'close'
			return
		# Close modal when history back
		Core.defaultRouter?.whenBack _close
		# DOM
		body= document.body
		body.classList.add 'modal-open'
		# Render
		element= _toHTMLElement html
		body.appendChild element
		# Promise
		_click= (event)->
			target= event.target
			if btn= target.closest('[d-value]')
				res btn.getAttribute 'd-value'
			else unless target.closest '.mini-container'
				res 'close'
			return
		element.addEventListener 'click', _click, false
		return
	# Add finnaly
	p= p.finally (res)->
		body= document.body
		body.removeChild element if element?
		body.classList.remove 'modal-open' unless body.querySelector ':scope>.modal'
		return res
	# Add APIs
	p.body= element
	p.close= _close
	# Return
	return p

alert: (message)->
	if typeof message is 'string' then opt= text: message
	else if message? then opt= message
	else throw new Error "Illegal arguments"
	opt.ok ?= i18n.ok or 'ok'
	@modal Core.html.alert opt
confirm: (message)->
	if typeof message is 'string' then opt= text: message
	else if message? then opt= message
	else throw new Error "Illegal arguments"
	opt.ok ?= i18n.ok or 'ok'
	opt.cancel ?= i18n.cancel or 'Cancel'
	@modal Core.html.confirm opt
