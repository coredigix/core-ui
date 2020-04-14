###*
 * Closest component
###

_closestComponent= (element)->
	return $ROOT_COMPONENT if element in [document, window]
	# Check for closest component
	while element and element isnt document
		if componentName= element.getAttribute COMPONENT_ATTR_NAME
			unless component= element[COMPONENT_SYMB]
				componentName= componentName.toLowerCase()
				if componentClazz= COMPONENTS_MAP[componentName]
					component= componentClazz._initComponent element
				else
					throw new Error "Unknown component #{componentName}"
			return component
		element= element.parentNode
	return $ROOT_COMPONENT
