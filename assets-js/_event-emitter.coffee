###*
 * Event emitter
###
class EventEmitter
	constructor: ->
		@_e= _create null # store events
		return
	###*
	 * Add event
	###
	on: (event, listener)->
		throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof event is 'string' and typeof listener is 'function'
		(@_e[event] ?= []).push listener, false
		this # chain
	###*
	 * Remove event
	###
	off: (event, listener)->
		throw new Error 'Event expected string' unless typeof event is 'string'
		switch arguments.length
			when 1
				delete @_e[event]
			when 2
				throw new Error 'listener expected function' unless typeof listener is 'function'
				queue= @_e[event]
				len= queue.length
				i=0
				while i < len
					if queue[i] is listener
						queue.slice i, 2
						len= queue.length
					else
						i+= 2
			else
				throw new Error 'Illegal arguments'
		this # chain
	###*
	 * Once
	###
	once: (event, listener)->
		throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof event is 'string' and typeof listener is 'function'
		(@_e[event] ?= []).push listener, true
		this # chain
	###*
	 * Emit event
	 * @promise
	###
	emit: (event)->
		queue= @_e[event]
		if queue
			args= [].slice.call arguments, 1
			len= queue.length
			i=0
			while i < len
				try
					listener= queue[i] 
					await Core.delay 0 # async call
					# call listener
					listener.apply this, args
					# remove if is once
					if queue[i+1]
						queue.slice i, 2
						len= queue.length
					else
						i+= 2
				catch err
					if event is 'error'
						Core.fatalError 'errorHandlers', err
					else
						await @emit 'error', err
			for listener in queue
				
					listener
		return
	###*
	 * eventNames
	###
	eventNames: -> Object.keys @_e
	###*
	 * Listeners
	###
	listeners: (event)-> @_e[event]?.slice 0

	###*
	 * Convert plain objects ito event emitters
	###
	@apply: (plainObj)->
		_defineProperty plainObj, '_e', value: _create null
		Object.setPrototypeOf plainObj, EventEmitter.prototype
		return
# interface
_defineProperty Core, 'EventEmitter', value: EventEmitter