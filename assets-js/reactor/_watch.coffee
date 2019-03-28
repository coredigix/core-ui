
###*
 * Native event listener
###

EVENT_QUEUE_STEP= 5
###
# eventQueue= [
	eventName,
	group,
	cssSelector,
	listener,
	originalListener
# ]
###
_nativeListener= (event, eventName, eventQueue, eventWrapper)->
	# go through elements
	element= event.target
	wrappedEvent= event
	while element and element isnt document
		# check if this element matches a CSS
		i=1 # the first element is the native listener, so escape it
		len= eventQueue.length
		while i<len
			# break unless has target event and matches a css selector
			break unless eventQueue[i] is eventName and element.matches eventQueue[i+2]
			# execute listener
			try
				wrappedEvent= new eventWrapper event, eventName, element
				eventQueue[i+3] wrappedEvent
				break unless wrappedEvent.bubblesImmediate
			catch err
				Reactor.fatalError 'uncaught error', err
			# next
			i+= EVENT_QUEUE_STEP
		# break if stopPropagation is called
		break unless wrappedEvent.bubbles
		# next
		element= element.parentNode
	return
_createNativeEventListener= (eventName, eventQueue, eventWrapper)->
	(event)-> _nativeListener event, eventName, eventQueue, eventWrapper

###*
 * Watch reactor API
 * watch events on components
 * @example
 * Reactor.watch 'cssSelector'
 * 		click: (event)->
 * 		dbClick: (event)->
 *
 * 		mouseout: (event)->
 * 		hout: (event)-> # special event, when mouse out from this element
 * 		hover: (event)-> # special event, when mouse get in this element for the first time
###
Reactor::watch= (selector, events)->
	try
		throw "Illegal arguments" unless arguments.length is 2
		throw "Selector expected string" unless typeof selector is 'string' # or typeof selector is 'function'
		throw "Illegal events" unless typeof events is 'object' and events

		for eventName, eventCb of events
			throw "Expected function as listener on event: #{eventName}" unless typeof eventCb is 'function'
			eventName = eventName.toLowerCase()
			# event groupement
			i = eventName.indexOf '.'
			if i is -1
				eventGrp= ''
			else
				eventGrp= eventName.substr i + 1
				eventName= eventName.substr 0, i
			# replace listener if special event
			specialEvents= @[SPECIAL_EVENTS]
			originalEventName= eventName
			originalEventListener= listener
			eventWrapper= EventWrapper
			if sp= specialEvents[eventName]
				eventName= sp[0] # wrapped event
				listener= sp[1] listener
				eventWrapper= sp[2] || EventWrapper # event wrapper
			# Create queue and native listener if not yeat created
			unless watchQueue= @[WATCH_QUEUE][eventName]
				sp= _createNativeEventListener originalEventName, watchQueue, eventWrapper
				watchQueue= @[WATCH_QUEUE][eventName]= [sp]
				# create native listener
				window.addEventListener eventName, sp,
					capture: true
					passive: true
			# add to queue
			watchQueue.push originalEventName, eventGrp, selector, listener, originalEventListener
		return
	catch err
		err= "Reactor::watch>> #{err}" if typeof err is 'string'
		throw err

###*
 * Unwatch
 * @example
 * Reactor.unwatch "selector"	# remove all listeners on this selector
 * Reactor.unwatch "selector", "eventName"	# remove this eventName of this selector
 * Reactor.unwatch "selector", "eventName1 eventName2 ..."	# remove this eventName of this selector
 * Reactor.unwatch "selector", "eventName.grp" # remove event listeners of this eventName and this group
 * Reactor.unwatch "selector", "eventName1.grp eventName1.grp2 eventName2.grp3" # remove event listeners of this eventName and this group
 * Reactor.unwatch "selector", ".grp1 .grp2 ..." # remove all event listeners of this group
 * Reactor.unwatch "selector", listener # remove all event with this listener
 * Reactor.unwatch "selector", "eventName", listener # remove this listener from this event
 * Reactor.unwatch null, XXX	# do XXX on all selectors
###
Reactor::unwatch= (selector, eventName, listener)->
	try
		throw "Selector expected string" if selector? and typeof selector isnt 'string' # or typeof selector is 'function'
		if typeof eventName is 'function'
			[eventName, listener]= [null, eventName]
		# test logic
		testLogic= []
		# target event
		if eventName
			i = eventName.indexOf '.'
			if i > -1
				eventGrp= eventName.substr i + 1
				eventName= eventName.substr 0, i
				# test group
				testLogic.push (arr, i)-> arr[i+1] is eventGrp
			# test eventName
			testLogic.push (arr, i)-> arr[i] is eventName
		# selector
		if selector
			testLogic.push (arr, i)-> arr[i+2] is selector
		# listener
		if typeof listener is 'function'
			testLogic.push (arr, i)-> arr[i+4] is listener
		# check queue logic
		checkQueue= (nativEvent, qu)->
			q= qu[nativEvent]
			if testLogic.length
				i=1
				len= q.length
				while i < len
					if testLogic.every (fx)-> fx q, i
						q.splice i, EVENT_QUEUE_STEP
						len= q.length
					else
						# next
						i+= EVENT_QUEUE_STEP
			else
				len= 1 # force to remove this queue
			# remove queue if no more listeners on it
			if len is 1
				window.removeEventListener nativEvent, q[0], true
				delete qu[nativEvent]
			return
		# check selector
		queue= @[WATCH_QUEUE]
		if eventName
			# get native event name
			if nativEvent= specialEvents[eventName]
				nativEvent= nativEvent[0]
			else
				nativEvent= eventName
			# remove listeners
			if queue[nativEvent]
				checkQueue nativEvent, queu
		# remove on all events
		else
			for nativEvent of queue
				checkQueue nativEvent, queue
		return
	catch err
		err= "Reactor::unwatch>> #{err}" if typeof err is 'string'
		throw err

