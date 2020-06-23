###*
 * Event wrapper
###
EventWrapper:		EventWrapper
F_FILES_LIST:		F_FILES_LIST

###*
 * Components
 * @param {String} componentName - name of the component
 * @param {Function} initFx - function($component){} init the component if required
###
ROOT_COMPONENT: ROOT_COMPONENT
getComponent: (element)->
	# Get element if css selector
	element= document.querySelector element if typeof element is 'string'
	# get component
	unless component= element[COMPONENT_SYMB]
		if componentName= element.getAttribute COMPONENT_ATTR_NAME
			componentName= componentName.toLowerCase()
			if componentClazz= COMPONENTS_MAP[componentName]
				component= new componentClazz element
			else
				throw new Error "Unknown component #{componentName}"
	return component
Component: Component
component: do ->
	# Copy private attributes
	_copyPrivate= (obj)->
		result= {}
		for k in _keys(obj)
			result[k]= obj[k].slice(0)
		return result
	# Interface
	return (componentName, componentClass)->
		try
			# Checks
			throw 'Illegal arguments' unless typeof componentName is 'string'
			componentName= componentName.toLowerCase()
			switch arguments.length
				# Get component
				when 1
					return COMPONENTS_MAP[componentName]
				# Define new Component
				when 2
					throw 'Illegal arguments' unless typeof componentClass is 'function'
					throw "Component already defined: #{componentName}" if COMPONENTS_MAP[componentName]
					throw 'The component didn\'t inherit from "Core.Component"' unless componentClass.prototype instanceof Component
				else
					throw 'Illegal arguments'
			# Save new Class
			COMPONENTS_MAP[componentName]= componentClass
			# LINK TO PREVIOUS CLASSES
			cl= componentClass
			COMPONENTS_MAP_CHILDS.set cl, [cl]
			until cl is Component
				cl= cl.__proto__
				if arr= COMPONENTS_MAP_CHILDS.get(cl)
					arr.push componentClass
				else
					throw new Error 'The component inherit from a non registered class'
			# COPY PRIVATE ATTRIBUTES FROM PARENT
			componentPrototype= componentClass.prototype
			componentPrototype._watch= 		_copyPrivate(componentPrototype._watch) # {eventName: [selector, [args], ...]}
			componentPrototype._watchSync=	_copyPrivate(componentPrototype._watchSync) # {eventName: [selector, [args], ...]}
			componentPrototype._linkEvents= _copyPrivate(componentPrototype._linkEvents) # {nativeEvent: [customEvents, ...]}
			componentPrototype._customEvents= _assign {}, componentPrototype._customEvents
			# Validation attributes
			componentPrototype._vAttrs= _create componentPrototype._vAttrs
		catch err
			err= new Error "::component>>#{err}" if typeof err is 'string'
			throw err
		this # chain

###*
 * ROUTE COMPONENT METHODS
###
watch:		Component.watch.bind Component
watchSync:	Component.watchSync.bind Component

enableAction:		Component.enableAction.bind Component
enableSyncAction:	Component.enableSyncAction.bind Component

# defineEvent:	ROOT_COMPONENT.defineEvent.bind ROOT_COMPONENT

# vCb:			ROOT_COMPONENT.vCb.bind ROOT_COMPONENT
# vSubmit:		ROOT_COMPONENT.vSubmit.bind ROOT_COMPONENT
# vAdd:			ROOT_COMPONENT.vAdd.bind ROOT_COMPONENT
# vType:			ROOT_COMPONENT.vType.bind ROOT_COMPONENT