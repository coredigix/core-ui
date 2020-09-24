###*
 * Detect form blur and focus to trigger validation
###
_evlistenerOptions= {capture: yes, passive: yes}
###* FOCUS & KEYDOWN ###
_focusListener= (event)->
	element= event.target
	if element.tagName is 'INPUT'
		# Check if add keydown listener
		# TODO
		# Remove active input
		# Remove validation indicators
		$inp= $(element)
		$inp.closest('.f-cntrl').removeClass('has-error has-done has-warn').find('.active-input').removeClass('active-input')
		$inp.addClass 'active-input'
		# Auto-select
		element.select() if element.hasAttribute 'd-select'
		# Autocomplete
		if args= element.getAttribute 'd-autocomplete'
			_closestComponent(element).autocomplete element, args
	return
window.addEventListener 'focus', _focusListener, _evlistenerOptions

###* BLUR EVENT ###
_blurListener= (event)->
	# remove keydown listener
	# window.removeEventListener 'keydown', _keydownListner, {capture: yes, passive: no}
	# Exec controls
	element= event.target
	if element is window
		for el in document.querySelectorAll('.coreComponent')
			try
				component.onWindowBlur event if component= el[COMPONENT_SYMB]
			catch err
				Core.fatalError 'Uncaught error', err
	else
		# Form fixes
		try
			# Fix input number decimals
			element.value= (+element.value).toFixed d if element.hasAttribute('d-decimals') and (d= +element.getAttribute 'd-decimals') and Number.isSafeInteger(d) and d>0
		catch err
			Core.error 'Form-Blur', err
		
			
		# Trigger blur
		_closestComponent(element.parentNode)._triggerBlur element
	return
window.addEventListener 'blur', _blurListener, _evlistenerOptions


###* FORM RESET ###
_formResetListener= (event)->
	form= event.target
	if form.targName is 'FORM'
		_closestComponent(form)._onFormReset event
	# ends
	return
window.addEventListener 'reset', _formResetListener, _evlistenerOptions

###* SUBMIT ###
_submitListener= (event)->
	form= event.target
	if form.hasAttribute 'v-submit'
		_closestComponent(form)._onSubmit event
	return
window.addEventListener 'submit', _submitListener, {capture: yes, passive: no}


###* Native window event ###
_windowResize= (event)->
	# Mobile VH fix
	vh= window.innerHeight
	# if mn= document.querySelector('.vh-min')
	# 	vh-= mn.offsetHeight
	document.documentElement.style.setProperty '--vh', "#{vh}px"
	# Trigger resize on all components
	for el in document.querySelectorAll('.coreComponent')
		try
			component.onWindowResize event if component= el[COMPONENT_SYMB]
		catch err
			Core.fatalError 'Uncaught error', err
	return
window.addEventListener 'resize', _windowResize, _evlistenerOptions

# Set vh
document.documentElement.style.setProperty '--vh', "#{window.innerHeight}px"