###*
 * Form validation events
 * Supported events
 * v-fixed: 
###

###*
 * Focus & keydown
###
_keydownListner= (event)->
	#TODO
	return
_focusListener= (event)->
	element= event.target
	if element.tagName is 'INPUT'
		# Check if add keydown listener
		# TODO
		# Remove validation indicators
		$inp= $(element)
		$inp.closest('.f-cntrl').removeClass('has-error has-done has-warn').find('.active-input').removeClass('active-input')
		$inp.addClass 'active-input'
		# Auto-select
		element.select() if element.hasAttribute 'd-select'
		# Autocomplete
		if args= element.getAttribute 'd-autocomplete'
			_closestComponent(element)._autocomplete element, args
	return
window.addEventListener 'focus', _focusListener, {capture: yes, passive: yes}
###*
 * Blur event
###
_blurListener= (event)->
	# remove keydown listener
	# window.removeEventListener 'keydown', _keydownListner, {capture: yes, passive: no}
	# Exec controls
	element= event.target
	unless element is window
		_closestComponent(element)._triggerBlurValidation element
	return
window.addEventListener 'blur', _blurListener, {capture: yes, passive: yes}


###*
 * Form reset
###
_formResetListener= (event)->
	form= event.target
	return unless form.targName is 'FORM'
	# remove state classes
	$('has-error has-done has-warn', form).removeClass 'has-error has-done has-warn'
	# empty file upload queue
	for inp in @querySelectorAll 'input[type="file"]'
		if queue= inp[F_FILES_LIST]
			queue.length= 0
	$('.files-preview', form).empty()
	# Emit this event
	_closestComponent(form).type.emit 'form-reset', event
	# ends
	return
window.addEventListener 'reset', _formResetListener, {capture: yes, passive: yes}

###*
 * Submit
###
_submitListener= (event)->
	form= event.target
	if form.hasAttribute 'v-submit'
		_closestComponent(form)._triggerSubmitValidation event
	return
window.addEventListener 'submit', _submitListener, {capture: yes, passive: no}
