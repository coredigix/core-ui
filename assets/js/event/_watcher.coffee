###*
 * Watch events using selectors
###
WATCHER_EVENTS	= Symbol 'events'
WATCHER_NATIVE_EVENT_LISTENERS	= Symbol 'native listeners'
WATCHER_EVENTS_Sync	= Symbol 'events'
WATCHER_NATIVE_EVENT_LISTENERS_Sync	= Symbol 'native listeners'
CUSTOM_EVENT_SYMB= Symbol 'custom events'
_customEvents= {}

ACTIONS_SYNC = Symbol 'action sync'
ACTION_NATIVE_SYNC = Symbol 'action native sync'
ACTIONS = Symbol 'actions'
ACTION_NATIVE = Symbol 'action native'

class _Watcher
	constructor: (options)->
		options ?= {}
		###
		events={
			eventName: [selector, wrappedEventName, group, nativeListener, originalListener ...]
		}
		###
		@[WATCHER_EVENTS]= _create null	# store event listeners and options
		@[WATCHER_NATIVE_EVENT_LISTENERS]= _create null # store event native listeners

		# Sync
		@[WATCHER_EVENTS_Sync]= _create null
		@[WATCHER_NATIVE_EVENT_LISTENERS_Sync]= _create null

		# Custom events
		@[CUSTOM_EVENT_SYMB]= _create _customEvents

		# Add action
		@_addActionAttr= options.addActionAttr or (eventName)-> 'd-'+eventName
		@_addActionSyncAttr= options.addActionSyncAttr or (eventName)-> 'd-'+eventName

		@[ACTIONS_SYNC]= _create null
		@[ACTION_NATIVE_SYNC]= _create null
		@[ACTIONS]= _create null
		@[ACTION_NATIVE]= _create null
		return
	###*
	 * Watch
	###
	watch: -> @_watch arguments, false, false
	watchSync: -> @_watch arguments, true, false
	_watch: (args, isSync, isUnwatch)->
		try
			# checks
			throw "Illegal arguments" unless args.length is 3
			selector= args[0]
			eventName= args[1]
			listener= args[2]
			throw "EventName expected string" unless typeof eventName is 'string'
			throw "Selector expected string" unless typeof selector is 'string' # or typeof selector is 'function'
			throw "Listener expected function" unless typeof listener is 'function'
			# accept multiple events
			eventTab= eventName.split /\s+/
			for eventName in eventTab
				# get Group
				idx= eventName.indexOf '.'
				if idx is -1
					group= null
				else if idx is 0
					throw "Expected an Event name, got: '#{eventName}'"
				else
					group= (eventName.substr idx+1) or null
					eventName= eventName.substr 0, idx
				eventName = eventName.toLowerCase()
				# sync or async
				if isSync
					events= @[WATCHER_EVENTS_Sync]
					nativeListeners= @[WATCHER_NATIVE_EVENT_LISTENERS_Sync]
				else
					events= @[WATCHER_EVENTS]
					nativeListeners= @[WATCHER_NATIVE_EVENT_LISTENERS]
				# wrap event
				if evt= @[CUSTOM_EVENT_SYMB][eventName]
					nativeListener= evt[1] listener, selector
					nativeEventName= evt[0]
				else
					nativeListener= listener
					nativeEventName= eventName
				# Add native listener
				unless eventQ= events[nativeEventName]
					eventQ= events[nativeEventName]= []
					nativeWindowListener= nativeListeners[nativeEventName]= _createNativeListener(eventQ)
					window.addEventListener nativeEventName, nativeWindowListener, {capture: true, passive: !isSync}
				# add listener
				eventQ.push selector, eventName, group, nativeListener, listener
		catch err
			err= new Error "::watch>> #{err}" if typeof err is 'string'
			throw err
		return

	###*
	 * Unwatch
	###
	unwatch: -> @_unwatch arguments, false
	unwatchSync: -> @_unwatch arguments, true
	_unwatch: (args, isSync)->
		try
			# extract vars
			selector= args[0]
			eventName= args[1]
			listener= args[2]
			# group
			if typeof eventName is 'string'
				idx= eventName.indexOf '.'
				if idx is -1
					group= null
				else
					group= (eventName.substr idx+1) or null
					eventName= eventName.substr 0, idx
				eventName = eventName.toLowerCase()
				# get native event name
				if eventName
					nativeEventName= eventName # <!> TODO
			# sync or async
			if isSync
				events= @[WATCHER_EVENTS_Sync]
				nativeListeners= @[WATCHER_NATIVE_EVENT_LISTENERS_Sync]
			else
				events= @[WATCHER_EVENTS]
				nativeListeners= @[WATCHER_NATIVE_EVENT_LISTENERS]
			# do
			rmNativeListeners= []
			# remove logic
			rmFxes= []
			if eventName then rmFxes.push (_, evntName)-> evntName is eventName
			if group then rmFxes.push (_, evntName, grp)-> grp is group
			if selector then rmFxes.push (select)-> 
			if listener then rmFxes.push (_, evntName, grp, nativeListener, originalListener)-> originalListener is listener

			# remove
			if nativeEventName
				if eventQ= events[nativeEventName]
					_removeNativeListeners eventQ, rmFxes
					rmNativeListeners.push nativeEventName unless eventQ.length
			else
				for k of events
					eventQ= events[k]
					_removeNativeListeners eventQ, rmFxes
					rmNativeListeners.push k unless eventQ.length
			# remove native listeners
			for k in rmNativeListeners
				window.removeEventListener k, nativeListeners[k], {capture: true, passive: !isSync}
				delete events[k]
				delete nativeListeners[k]
		catch err
			err= new Error "::unwatch>> #{err}" if typeof err is 'string'
			throw err
		this # chain

	###*
	 * addEvent
	###
	addEvent: (eventName, nativeEventName, listenerGenerator)->
		try
			# Checks
			throw 'eventName expected string' unless typeof eventName is 'string'
			throw 'nativeEventName expected string' unless typeof nativeEventName is 'string'
			throw 'listenerGenerator expected function' unless typeof nativeEventName is 'function'
			customEvnts= @[CUSTOM_EVENT_SYMB]
			throw "Event already set: #{eventName}" if customEvnts.hasOwnProperty eventName
			customEvnts[eventName]= [nativeEventName, listenerGenerator]
		catch err
			err= new Error "::addEvent>> #{err}" if typeof err is 'string'
			throw err
		this # chain

	###*
	 * Add action
	###
	addAction: -> @_addAction arguments, false
	addActionSync: -> @_addAction arguments, true
	_addAction: (args, isSync)->
		try
			throw 'Expected 3 arguments' unless args.length is 3
			# arguments
			eventName= args[0]
			handlerName= args[1]
			handler= args[2]
			# Checks
			throw 'eventName expected string' unless typeof eventName is 'string'
			eventName= eventName.toLowerCase()
			throw "Grouping not allowed: #{eventName}" if ~eventName.indexOf('.')
			throw 'handlerName expected string' unless typeof handlerName is 'string'
			throw 'handler expected function' unless typeof handler is 'function'
			# actions
			if isSync
				actions= @[ACTIONS_SYNC]
				nativeListeners= @[ACTION_NATIVE_SYNC]
			else
				actions= @[ACTIONS]
				nativeListeners= @[ACTION_NATIVE]
			# create native event
			unless q= actions[eventName]
				q= actions[eventName]= _create null
				_createActionNativeEvent this, eventName, q, nativeListeners, isSync
			throw "Action already set: #{eventName}.#{handlerName}" if q[handlerName]
			q[handlerName]= handler
		catch err
			err= new Error "::addAction>> #{err}" if typeof err is 'string'
			throw err
		return
	###*
	 * Remove action
	###
	removeAction: -> @_removeAction arguments, false
	removeActionSync: -> @_removeAction arguments, true
	_removeAction: (args, isSync)->
		try
			throw 'Expected 2 arguments' unless args.length is 2
			# arguments
			eventName= args[0]
			handlerName= args[1]
			# Checks
			throw 'eventName expected string' unless typeof eventName is 'string'
			throw 'handlerName expected string' unless typeof handlerName is 'string'
			# actions
			if isSync
				actions= @[ACTIONS_SYNC]
				nativeListeners= @[ACTION_NATIVE_SYNC]
			else
				actions= @[ACTIONS]
				nativeListeners= @[ACTION_NATIVE]
			# remove
			if q= actions[eventName]
				delete q[handlerName]
				unless _keys(q).length
					nativeListener= nativeListeners[eventName]
					# wrap event
					if evt= @[CUSTOM_EVENT_SYMB][eventName]
						nativeEventName= evt[0]
					else
						nativeEventName= eventName
					# remove listener
					window.removeEventListener nativeEventName, nativeListener, {capture: true, passive: !isSync}
					# delete
					delete actions[eventName]
					delete nativeListeners[eventName]
		catch err
			err= new Error "::removeAction>> #{err}" if typeof err is 'string'
			throw err
		this # chain
### REMOVE LISTENERS ###
_removeNativeListeners= (q, rmCb)->
	if q
		i=0
		len= q.length
		while i<len
			# [selector, wrappedEventName, group, nativeListener, originalListener]
			j=i
			selector=	q[i++]
			wrappedEventName=	q[i++]
			group=	q[i++]
			nativeListener=	q[i++]
			originalListener=	q[i++]
			# check
			if rmCb.every (fx)-> fx selector, wrappedEventName, group, nativeListener, originalListener
				q.splice j, 5
				i=j
				len= q.length
	return

### ADD NATIVE LISTENERS ###
_createNativeListener= (queue)->
	# [selector, wrappedEventName, group, nativeListener, originalListener ...]
	(event)->
		try
			# element
			element= event.target
			return if element in [window, document]
			wrappedEvent= event
			# go through elements
			queueLen= queue.length
			while element and element isnt document
				# match css
				i=0
				while i<queueLen
					selector= queue[i]
					if element.matches selector
						try
							wrappedEventName= queue[i+1]
							wrappedEvent= new EventWrapper event, wrappedEventName, selector, element
							# exec listener
							queue[i+3].call element, wrappedEvent
							# break if stop immediate bubbles
							break unless wrappedEvent.bubblesImmediate
						catch err
							Core.fatalError 'watcher', err
					# next
					i+= 5
				# break if stopPropagation is called
				break unless wrappedEvent.bubbles
				# next
				element= element.parentNode
		catch err
			Core.fatalError 'watcher', err
		return

# addAction:: CREATE NATIVE EVENT
_createActionNativeEvent= (watcher, eventName, q, nativeListeners, isSync)->
	throw "Native event already set: #{eventName}" if nativeListeners[eventName]
	# action attribute
	if isSync
		actionAttr= watcher._addActionSyncAttr eventName
	else
		actionAttr= watcher._addActionAttr eventName
	actionSelector= "[#{actionAttr}]"
	# create listener
	listener= (event)->
		attrV= @getAttribute actionAttr
		if cb= q[attrV]
			cb.call this, event
		else
			Core.warn '::addAction', "Unknown action: #{attrV}"
		return
	# wrap event
	if evt= watcher[CUSTOM_EVENT_SYMB][eventName]
		listener= evt[1] listener, actionSelector
		nativeEventName= evt[0]
	else
		nativeEventName= eventName

	nativeListener= nativeListeners[eventName]= (event)->
		# element
		element= event.target
		wrappedEvent= event
		while element and element isnt document
			if handlerName= element.getAttribute actionAttr
				try
					listener.call element, new EventWrapper event, eventName, actionSelector, element
				catch err
					Core.fatalError '::Action', err
			# break if stopPropagation is called
			break unless wrappedEvent.bubbles
			# next
			element= element.parentNode
		return
	window.addEventListener nativeEventName, nativeListener, {capture: true, passive: !isSync}
	return
