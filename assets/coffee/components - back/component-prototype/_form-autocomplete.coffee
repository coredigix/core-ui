
###*
 * Autocomplete
###
_autocomplete: do ->
	autocompleteSymb= Symbol('autocomplete')
	# Logic
	_doLogic= (element, factory, controller, popup)->
		try
			# Abort previous calls
			popup.ajax?.abort()
			# Load data
			call= popup.ajax= controller.getData.call element, element.value
			data= await call
			popup.ajax= null
			# Render
			result= await controller.render.call element, data, popup

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
				factory.emit 'error', err
		return
	# Interface
	(element, args)->
		try
			# Get autocomplete controller
			args= args.trim().split /\s+/
			cbName= args[0]
			# Get the component
			factory= @factory
			throw "Unknown method: #{cbName}" unless controller= factory._acMethods[cbName]
			# Create modal
			popup= element[autocompleteSymb] or Core._popup element, autocompleteSymb, -1, no
			# Add event listeners
			onKeyup= (event)->
				unless event.keyCode in [9, 13, 27, 37, 38, 39, 40] # tab, return, escape and arrows
					_doLogic this, factory, controller, popup
				return
			onblur= (event)->
				element.removeEventListener 'blur', onblur, false
				element.removeEventListener 'keyup', onKeyup, false
				return
			element.addEventListener 'blur', onblur, false
			element.addEventListener 'keyup', onKeyup, false
			# Execute logic
			_doLogic element, factory, controller, popup
		catch err
			err= "autocomplete: #{err}" if typeof err is 'string'
			@emit 'error', err
		return