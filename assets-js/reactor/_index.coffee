###*
 * Reactor api
 * (to be exported in future to single api)
###

WATCH_QUEUE= Symbol 'watches'
SPECIAL_EVENTS= Symbol 'special events'
EVENT_NAME_CHECK= /^[a-z_-]+$/

###*
 * [nativeEventName, listenerGen, eventWrapper]
###
BASIC_SPECIAL_EVENTS= _create null

window.Reactor= class Reactor
	constructor: ->
		###*
		 * nativeEventName: [eventName, group, cssSelector, listener, ...]
		###
		@[WATCH_QUEUE]= _create null
		###*
		 * specialEvent: [wrappedEventName, listenerGen(listener)]
		###
		@[SPECIAL_EVENTS]= _create BASIC_SPECIAL_EVENTS
		return
	###*
	 * Create special event
	 * @param {String} eventName - name of the event
	 * @param {String} nativeEventName - Browser native event that will trigger this one
	 * @param {Function} listenerGen - function that will wrap the listeners
	 * @optional @param {function} eventWrapper - Wrapper for the event, must extends Reactor.EventWrapper
	###
	addSpecialEvent: (eventName, nativeEventName, listenerGen, eventWrapper)->
		try
			throw 'Illegal arguments' unless arguments.length is 3 and typeof eventName is 'string' and typeof nativeEventName is 'string' and typeof listenerGen is 'function'
			throw "Illegal event name: #{eventName}" unless EVENT_NAME_CHECK.test eventName
			q= @[SPECIAL_EVENTS]
			throw new Error "Event #{eventName} already set" if q[eventName]
			q[eventName]= [nativeEventName, listenerGen, eventWrapper]
			this # chain
		catch err
			err= "Reactor::addSpecialEvent>> #{err}" if typeof err is 'string'
			throw err

# log
_defineProperties Reactor,
	fatalError: value: Core.fatalError # use core fatalError
	error: value: Core.error # use core error
	warn: value: Core.warn # use core warn
	info: value: Core.info # use core info

# utils
_hasElement= (event, element)->
	el= event.target
	while el
		return true if el is element
		el= el.parentNode
	return false

#=include _event-wrapper.coffee
#=include _watch.coffee
#=include _basic-special-events.coffee