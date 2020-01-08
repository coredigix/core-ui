###*
 * Event wrapper
###
class EventWrapper
	constructor: (event, eventName, selector, currentTarget)->
		@originalEvent= event
		@type= eventName
		# target
		@target= event.target
		@currentTarget= currentTarget
		# flags
		@bubbles= true
		@bubblesImmediate= yes
		@selector= selector
		return

	### HELPERS ###
	stopPropagation: ->
		@bubbles= off
		this # chain
	stopImmediatePropagation: ->
		@bubbles= off
		@bubblesImmediate = off
		this # chain

### GETTERS ONCE ###
EventWrapperPrototype= EventWrapper.prototype
['altKey', 'ctrlKey', 'shiftKey', 'timeStamp', 'which', 'x', 'y'].forEach (k)->
	_defineProperty EventWrapperPrototype, k, get: ->
		v= @originalEvent[k]
		_defineProperty this, k, value: v
		return v
	return