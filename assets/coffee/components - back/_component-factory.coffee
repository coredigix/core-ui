###*
 * PARAMS
###
_componentsCustomEvents= {} # Global custom events
_componentsMapEventsToCustom= {} # Map native events to custom events
_componentsFormBlurActions=
	#=include form-validators/_blur-actions.coffee
_componentvTypes=
	#=include form-validators/_validation-types.coffee
_componentsVCb= {}
_componentsVSubmit=
	#=include form-validators/_submit-predefined.coffee
###* AUTOCOMPLETE ###
_componentAutocomplete=
	#=include autocomplete-controllers/_*.coffee
# default_options= {}
# 	# actionPrefix: 'd-'
# 	# validationPrefix: 'v-'
COMPONENT_ATTR_NAME= 'd-component'
COMPONENTS_MAP= {} # Store all components
DEFAULT_EVENT_LISTENER_WRAPPER= (listener)-> listener
###*
 * Default init function
###
VOID_FX= ->
###*
 * Components
 * @emit 'validate'  {component, element, status: Boolean}
 * @emit 'create'	- {component} when a new component is detected
 * @emit 'form-reset' - {form} when a form inside component is reset
 * @emit 'form-error' - {element, form, error} when an error with a form control
 * @emit 'submitted'	- {form, result} when form submitted
 * @emit 'submit-error' - {form, error} when submit errored
###
class ComponentFactory extends EventEmitter
	constructor: (componentClass)->
		super()
		# @_options= _assign {}, default_options, options
		componentClass.factory= this
		@_componentClass= componentClass
		# Events
		@_watch= {}
		@_watchSync= {}
		@_actions= {}
		@_actionsSync= {}
		@_customEvents= _create _componentsCustomEvents
		@_mapCustomEvents= {} # map native event to custom events
		# Validation
		@_vCb= _create _componentsVCb
		@_vSubmit= _create _componentsVSubmit
		@_blurActions= _create _componentsFormBlurActions
		@_vTypes= _create _componentvTypes
		# Autocomplete
		@_acMethods= _create _componentAutocomplete
		return
	###*
	 * Add watcher
	###
	watch: (cssSelector, eventName, handler)-> @_watchEvnt cssSelector, eventName, handler, no
	watchSync: (cssSelector, eventName, handler)-> @_watchEvnt cssSelector, eventName, handler, yes
	_watchEvnt: (cssSelector, eventName, handler, isSync)-># Checks
		try
			throw 'Illegal css-selector' unless typeof cssSelector is 'string'
			throw 'eventName expected string' unless typeof eventName is 'string'
			throw 'handler expected function' unless typeof handler is 'function'
			# map
			watchMap= if isSync then @_watchSync else @_watch
			# Add event
			eventName = eventName.toLowerCase()
			eventWatch= watchMap[eventName]?= []
			# find native event and wrap handler
			if nativeEvent= @_customEvents[eventName]
				handler= nativeEvent.wrapHandler handler
				evnt= nativeEvent.nativeEvent
			else
				evnt= eventName
			# Enable native event
			_enableNativeEvent evnt, isSync
			# Add to queue
			eventWatch.push cssSelector, handler
		catch err
			err= new Error "::watch>> #{err}" if typeof err is 'string'
			throw err
		this # chain
	###*
	 * Add action
	###
	addAction: (eventName, handlerName, handler)-> @_addAction eventName, handlerName, handler, no
	addActionSync: (eventName, handlerName, handler)-> @_addAction eventName, handlerName, handler, yes
	_addAction: (eventName, handlerName, handler, isSync)->
		try
			# Checks
			throw 'Illegal EventName' unless typeof eventName is 'string' and not ~eventName.indexOf('.')
			throw 'Illegal handler name' unless typeof handlerName is 'string' and not ~handlerName.indexOf(' ')
			throw 'Illegal handler' unless typeof handler is 'function'
			eventName= eventName.toLowerCase()
			handlerName= handlerName.toLowerCase()
			# map
			actions= if isSync then @_actionsSync else @_actions
			# Add event
			eventActions= actions[eventName]?= {}
			throw "Action already set: #{eventName}.#{handlerName}" if eventActions[handlerName]
			# find native event and wrap handler
			if nativeEvent= @_customEvents[eventName]
				handler= nativeEvent.wrapHandler handler
				evnt= nativeEvent.nativeEvent
			else
				evnt= eventName
			# Enable native event
			_enableNativeEvent evnt, isSync
			# Add
			eventActions[handlerName]= handler
		catch err
			err= new Error "::addAction>> #{err}" if typeof err is 'string'
			throw err
		this # chain
	###*
	 * Create custom events
	 * @example
	 * ::defineEvent('move', 'mousedown', function(listener){})
	###
	defineEvent: (eventName, nativeEventName, listenerGenerator, eventWrapper)->
		try
			# Check
			throw 'Arguments count error' unless arguments.length in [3,4]
			throw 'eventName expected string' unless typeof eventName is 'string'
			throw 'nativeEventName expected string' unless typeof nativeEventName is 'string'
			# Listener wrapper
			if listenerGenerator?
				throw 'eventWrapper expected function' unless typeof listenerGenerator is 'function'
			else
				listenerGenerator= DEFAULT_EVENT_LISTENER_WRAPPER
			eventName= eventName.toLowerCase()
			nativeEventName= nativeEventName.toLowerCase()
			# Event wrapper
			throw new Error "Event already defined: #{eventName}" if @_customEvents[eventName]
			eventWrapper ?= EventWrapper
			# Add
			@_customEvents[eventName]=
				nativeEvent:	nativeEventName
				wrapHandler:	listenerGenerator
				eventWrapper:	eventWrapper
			# Add dispatcher to that event
			(@_mapCustomEvents[nativeEventName]?= []).push eventName, eventWrapper
			this # chain
		catch err
			err= new Error "::defineEvent>> #{err}" if typeof err is 'string'
			throw err
	###*
	 * Load dispatcher queue for a native event
	###
	# _getDispatcher: (nativeEventName)->
	# 	unless dsp= @_mapCustomEvents[nativeEventName]
	###*
	 * Create component
	 * @private
	###
	getComponent: ($component)->
		unless component= $component[COMPONENT_SYMB]
			component= new @_componentClass($component)
			@emit 'create', component: component
		return component
	###*
	 * Dispatch event
	 * @private
	###
	_dispatch: (isSync, eventName, event, eventPath, currentTarget, componentTarget)->
		# Create component object if not yeat created
		unless component= currentTarget[COMPONENT_SYMB]
			component= @getComponent currentTarget
		# Dispatch native event if not modified
		unless @_customEvents[eventName]
			evnt= new EventWrapper isSync, eventName, eventName, event, eventPath, currentTarget, component, componentTarget
			@_dispatchApply isSync, eventName, evnt, eventPath, currentTarget, componentTarget
		# Apply dispatch
		<% function _componentApplyDisaptch(){ %>
			i= 0
			len= customEvents.length
			while i<len
				try
					customEvent= customEvents[i++]
					eventWrapperClass= customEvents[i++]
					evnt= new eventWrapperClass isSync, eventName, customEvent, event, eventPath, currentTarget, component, componentTarget
					@_dispatchApply isSync, customEvent, evnt, eventPath, currentTarget, componentTarget
				catch err
					@emit 'error',
						eventName: eventName
						error: err
		<% } %>
		# Dispatch root wrapped events
		if customEvents= _componentsMapEventsToCustom[eventName]
			<% _componentApplyDisaptch() %>
		# Dispatch local custom events
		if (@_mapCustomEvents isnt _componentsMapEventsToCustom) and (customEvents= @_mapCustomEvents[eventName])
			<% _componentApplyDisaptch() %>
		return
	_dispatchApply: (isSync, customEvent, wrappedEvent, eventPath, currentTarget, componentTarget)->
		element= componentTarget
		component= currentTarget[COMPONENT_SYMB]
		# ACTIONS
		if isSync
			attrName= "d-#{customEvent}-sync"
			actions= @_actionsSync[customEvent]
			rootActions= ROOT_COMPONENT._actionsSync[customEvent]
			# CSS Selectors
			eventWatchers= @_watchSync[customEvent]
		else
			attrName= "d-#{customEvent}"
			actions= @_actions[customEvent]
			rootActions= ROOT_COMPONENT._actions[customEvent]
			# CSS Selectors
			eventWatchers= @_watch[customEvent]
		# Root CSS selectors
		if ROOT_COMPONENT is this
			rootEventWatchers= null
		else
			rootEventWatchers= if isSync then ROOT_COMPONENT._watchSync else ROOT_COMPONENT._watch
		# Loop
		while element and element isnt currentTarget
			# Check for attribute action event
			if attr= element.getAttribute attrName
				try
					attr= attr.trim().split /\s+/
					attrAction= attr[0].toLowerCase()
					throw "Unknown action #{attrAction}" unless handler= actions?[attrAction] or rootActions?[attrAction]
					handler.call element, wrappedEvent, component, attr
				catch err
					@emit 'error', err
			
			# CSS selectors
			<% function _dispatchWatch(){ %>
				i= 0
				len= eventWatchersQueue.length
				while i<len
					selector= eventWatchersQueue[i++]
					handler= eventWatchersQueue[i++]
					try
						handler.call element, wrappedEvent, component if element.matches selector
						# break if stop immediate bubbles
						break unless wrappedEvent.bubblesImmediate
					catch err
						@emit 'error', err
			<% } %>
			if eventWatchers # [cssSelector, handler, ...]
				eventWatchersQueue= eventWatchers
				<% _dispatchWatch() %>
			# route watcher
			if rootEventWatchers
				eventWatchersQueue= rootEventWatchers
				<% _dispatchWatch() %>
			# break if stopPropagation is called
			break unless wrappedEvent.bubbles
			# next
			element= element.parentNode
		return
	###*
	 * VALIDATION
	###
	###*
	 * Add validator callback
	 * @param  {String}   name - callback name
	 * @param  {function} cb.call(element, value, param, component)   - callback
	 * 
	 * @return {string}        value to replace (or same value as input)
	 * @throws {false} If value is invalid
	 * @throws {'warn'} If has warning
	###
	vCb: (name, cb)->
		try
			throw "Expected 2 arguments" unless arguments.length is 2
			throw "Expected cb name" unless typeof name is 'string'
			throw "Expected cb as function" unless typeof cb is 'function'
			name= name.toLowerCase()
			throw "Callback already set: #{name}" if @_vCb[name]
			@_vCb[name]= cb
		catch err
			err= new Error "::vCb>> #{err}" if typeof err is 'string'
			throw err
		this # chain
	###*
	 * Validate form controls just before submit
	 * @param {String} name - name of the callback
	 * @param {Function} cb.call(form, event, parts, component) - throws false if validation failed
	###
	vSubmit: (name, cb)->
		try
			throw "Expected 2 arguments" unless arguments.length is 2
			throw "Expected cb name" unless typeof name is 'string'
			throw "Expected cb as function" unless typeof cb is 'function'
			name= name.toLowerCase()
			throw "Callback already set: #{name}" if @_vSubmit[name]
			@_vSubmit[name]= cb
		catch err
			err= new Error "::vSubmit>> #{err}" if typeof err is 'string'
			throw err
		this # chain
	###*
	 * Add validator onBlur
	 * @example
	 * 		::vAdd('v-max', function.call(element, value, param, component){+element.value < +param})
	###
	vAdd: (attrName, validator)->
		throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof attrName is 'string' and typeof validator is 'function'
		throw new Error "::vAdd already set: #{attrName}" if @_blurActions[attrName]
		@_blurActions[attrName]= validator
		this # chain
	###*
	 * Add validation type
	 * @param  {String} typeName  - type name
	 * @param  {Function} validator.call(element, value, component) - validator
	 * @return {[type]}           [description]
	###
	vType: (typeName, validator)->
		throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof typeName is 'string' and typeof validator is 'function'
		throw new Error "::vAdd already set: #{typeName}" if @_vTypes[typeName]
		@_vTypes[typeName]= validator
		this # chain
	
	###_triggerKeydownValidation: (event)->
		return###
	#=include component-factory-prototype/_*.coffee

###*
 * Create root component
###
ROOT_COMPONENT= new ComponentFactory(Component)
ROOT_COMPONENT._customEvents=		_componentsCustomEvents
ROOT_COMPONENT._mapCustomEvents=	_componentsMapEventsToCustom
ROOT_COMPONENT._blurActions=		_componentsFormBlurActions
ROOT_COMPONENT._vTypes=				_componentvTypes
ROOT_COMPONENT._vCb=				_componentsVCb
ROOT_COMPONENT._vSubmit=			_componentsVSubmit
ROOT_COMPONENT._acMethods=		_componentAutocomplete

$ROOT_COMPONENT= ROOT_COMPONENT.getComponent window