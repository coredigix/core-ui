###*
 * Native Event wrapper
###
Reactor.EventWrapper= class EventWrapper
	constructor: (event, eventName, currentTarget)->
		@originalEvent= event
		@type= eventName
		@currentTarget= currentTarget
		@bubbles= true
		@bubblesImmediate= yes
		@target= event.target
		return

	### HELPERS ###
	stopPropagation: ->
		@bubbles= off
		this # chain
	stopImmediatePropagation: ->
		@bubbles= off
		@bubblesImmediate = off
		this # chain

	altKey: -> @originalEvent.altKey

EventWrapperPrototype= EventWrapper.prototype
# GETTERS
_defineProperties EventWrapperPrototype,
	###*
	 * Get path
	###
	path: get: ->
		path= @originalEvent.path
		unless path
			path= []
			ele= event.target
			while ele
				path.push ele
				ele=ele.parentNode
			ele.push window
		_defineProperty this, 'path', value: path
		return path

### GETTERS ONCE ###
['altKey', 'ctrlKey', 'shiftKey', 'defaultPrevented', 'timeStamp', 'which', 'x', 'y'].forEach (k)->
	_defineProperty EventWrapperPrototype, k, get: ->
		v= @originalEvent[k]
		_defineProperty this, k, value: v
		return v
	return