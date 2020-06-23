###*
 * Actions
 * @example
 * component.enableAction 'click'
###
@enableAction: (eventName)-> @_enableNativeEvent arguments, no
@enableSyncAction: (eventName)-> @_enableNativeEvent arguments, yes
@_enableNativeEvent: do ->
	_syncListeners= {}		# Map sync events
	_asyncListeners= {}	# Map async events
	# Create listener
	_dispatch= (event, eventName, isSync)->
		target= element= event.target
		unless element in [window, document]
			# Run components
			while element and element isnt document
				# Check for component
				if componentName= element.getAttribute COMPONENT_ATTR_NAME
					componentName= componentName.toLowerCase()
					if componentClass= COMPONENTS_MAP[componentName]
						component= element[COMPONENT_SYMB] or new componentClass(element)
						component.dispatch eventName, event, target, isSync
						target= element
					else
						Core.warn 'COMPONENTS', "Unknown component #{componentName}"
				# next
				element= element.parentNode
		# Run global component
		ROOT_COMPONENT.dispatch eventName, event, target, isSync
		return
	# Create listener
	_createListener= (eventName, isSync)-> (event)-> _dispatch event, eventName, isSync
	# Interface
	(events, isSync)->
		for eventName in events
			# Check
			throw new Error '::enableAction>> Illegal eventName' unless typeof eventName is 'string' and EVENT_NAME_REGEX.test eventName
			# Get native event
			ref= eventName
			ref2= eventName
			customEvents= @prototype._customEvents
			while ref= customEvents[ref]
				throw "Event link circle detected for event: #{eventName}" if ref is eventName
				ref2= ref
			eventName= ref2
			# Add event listener
			listeners= if isSync then _syncListeners else _asyncListeners
			unless listeners[eventName]
				listeners[eventName]= listener= _createListener eventName, isSync
				window.addEventListener eventName, listener, {capture: true, passive: !isSync}
		# Chain
		this