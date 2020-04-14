###*
 * Add event action
 * @private
###
_enableNativeEvent= do ->
	_syncEvents= {}		# Map sync events
	_asyncEvents= {}	# Map async events
	# create listener
	_createListener= (eventName, isSync)->
		(event)->
			# create event path
			componentTarget= element= event.target
			eventPath= []
			return if element in [window, document]
			while element and element isnt document
				eventPath.push element
				element= element.parentNode
			# Run components
			for element in eventPath
				if componentName= element.getAttribute COMPONENT_ATTR_NAME
					componentName= componentName.toLowerCase()
					if component= COMPONENTS_MAP[componentName]
						component._dispatch isSync, eventName, event, eventPath, element, componentTarget
						componentTarget= element
					else
						Core.warn 'COMPONENTS', "Unknown component #{componentName}"
			# Run global
			ROOT_COMPONENT._dispatch isSync, eventName, event, eventPath, element, componentTarget
			return
	# Interface
	return (eventName, isSync)->
		eventMap= if isSync then _syncEvents else _asyncEvents
		unless eventMap[eventName]
			eventMap[eventName]= listener= _createListener eventName, isSync
			window.addEventListener eventName, listener, {capture: true, passive: !isSync}
		return