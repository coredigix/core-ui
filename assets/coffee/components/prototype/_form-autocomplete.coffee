###*
 * Autocomplete
###
autocomplete: do ->
	autocompleteSymb= Symbol('autocomplete')
	# Logic
	_doLogic= (element, component, controller, popup)->
		try
			# Abort previous calls
			popup.ajax?.abort()
			# Load and render data
			call= popup.ajax= controller.getData.call element, element.value, component
			data= await call
			popup.ajax= null
			# Render
			result= await controller.render.call element, data, popup, component
			# Render
			if result
				# Add content
				$popupBody= popup.$body
				if typeof result is 'string'
					$popupBody.innerHTML= result
				else
					$popupBody.removeChild child while child= $popupBody.firstChild
					$popupBody.appendChild result
				# Show popup
				popup.open()
		catch err
			unless err?.aborted
				err= "autocomplete: #{err}" if typeof err is 'string'
				component.emit 'error', err
		return
	# Interface
	(element, args)->
		try
			# Get autocomplete controller
			args= args.trim().split /\s+/
			cbName= args[0]
			# Get the component
			throw "Unknown method: #{cbName}" unless controller= @[cbName]
			throw "Expected #{cbName}.getData to be function" unless typeof controller.getData is 'function'
			throw "Expected #{cbName}.render to be function" unless typeof controller.render is 'function'
			# Create modal
			popup= element[autocompleteSymb] or Core._popup element, autocompleteSymb, -1, no
			# Add event listeners
			onKeyup= (event)=>
				unless event.keyCode in [9, 13, 27, 37, 38, 39, 40] # tab, return, escape and arrows
					_doLogic element, this, controller, popup
				return
			onblur= (event)->
				element.removeEventListener 'blur', onblur, false
				element.removeEventListener 'keyup', onKeyup, false
				return
			element.addEventListener 'blur', onblur, false
			element.addEventListener 'keyup', onKeyup, false
			# Execute logic
			_doLogic element, this, controller, popup
		catch err
			err= "autocomplete: #{err}" if typeof err is 'string'
			@emit 'error', err
		return


###*
 * Autocomplete predefined
###
datepicker:
	getData: (txt)-> txt
	render: (data, popup)->
		datePickerComponentFactory= COMPONENTS_MAP['date-picker']
		# Create date picker
		if datePicker= popup.$body.querySelector '[d-component="date-picker"]'
			datePicker= datePickerComponentFactory.getInstance datePicker
			datePicker.setValue data
			popup.open()
			return null
		else
			# Load attributes
			attrs= {}
			for key in @getAttributeNames()
				attrs[key]= @getAttribute(key) if key.startsWith('d-')
			attrs['d-value']?= data
			# HTML element
			result= _toHTMLElement Core.html.datePickerPopup(attrs)
			datePickerComponentFactory.getInstance result.querySelector '[d-component="date-picker"]'
			return result
	# onSelect: (option)->
	# 	console.log '---- datepicker selected: ', option
	# 	return