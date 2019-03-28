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
WATCH_QUEUE= Symbol 'watches'
Reactor::watch= (selector, events)->
	throw new Error "Illegal arguments" unless arguments.length is 2
	throw new Error "Selector expected string" unless typeof selector is 'string' # or typeof selector is 'function'
	throw new Error "Illegal events" unless typeof events is 'object' and events

	for eventName, eventCb of events
		eventName = eventName.toLowerCase()
		# event groupement
		i = eventName.indexOf '.'
		if i is -1
			eventGrp= ''
		else
			eventGrp= eventName.substr i + 1
			eventName= eventName.substr 0, i
		# value check
		if typeof eventCb is 'function'
			eventCb=
				passive: no
				force: no
				listener: eventCb
		else unless eventCb and typeof eventCb.listener is 'function'
			throw new Error "Event listener expected function at: #{eventName}"
		# prepare queue
		eventsQueu= ( ((@[WATCH_QUEUE] ?= _create null)[selector] ?= _create null)[eventName] ?= _create null )[eventGrp] ?= []
		# add listener
		eventsQueu.push 
