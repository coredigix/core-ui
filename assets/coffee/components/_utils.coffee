###*
 * Closest component
###
_closestComponent= (element)->
	return ROOT_COMPONENT if element in [document, window]
	# Check for closest component
	while element and element isnt document
		if componentName= element.getAttribute COMPONENT_ATTR_NAME
			unless component= element[COMPONENT_SYMB]
				componentName= componentName.toLowerCase()
				if componentClazz= COMPONENTS_MAP[componentName]
					component= new componentClazz element
				else
					throw new Error "Unknown component #{componentName}"
			return component
		element= element.parentNode
	return ROOT_COMPONENT

# Read file
_readFile= (file)->
	new Promise (res, rej)->
		reader = new FileReader()
		reader.onload= -> res reader.result
		reader.onerror= rej
		reader.readAsDataURL file
		return

# Is parent of
_isParentOf= (parent, child)->
	while child
		return yes if child is parent
		child= child.parentNode
	return no

# Event name check
EVENT_NAME_REGEX= /[^\s.]/