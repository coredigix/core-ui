###*
 * Event emitter
###
# UTILS
_eventEmitterClean= (obj, eventName, queue, cb)->
	if queue
		len= queue.length
		i=0
		while i < len
			if cb queue, i
				arr= queue.slice i, 3
				len= queue.length
				_eventEmitterEmitRemove obj, eventName, arr
			else
				i+= 3
	return
_eventEmitterEmitRemove= (obj, eventName, arr)->
	if arr and obj._e.removeListener
		len= arr.length
		i= 0
		while i < len
			obj.emit 'removeListener', {eventName: eventName, listener: arr[i++], group: arr[i++], isOnce: arr[i++]}
	return
_eventEmitterAddListener= (obj, eventName, listener, isOnce)->
	# plain eventName
	if Array.isArray eventName
		for el in eventName
			_eventEmitterAddListener obj, el, listener, isOnce
		return
	# Plain listener
	if Array.isArray listener
		for el in listener
			_eventEmitterAddListener obj, eventName, el, isOnce
		return
	# add
	throw new Error 'Expected String and function as args' unless typeof eventName is 'string' and typeof listener is 'function'
	# get group
	idx= eventName.indexOf '.'
	if idx is -1
		group= null
	else if idx is 0
		throw 'Expected an event name'
	else
		group= (eventName.substr idx+1) or null
		eventName= eventName.substr 0, idx
	eventName = eventName.toLowerCase()
	# add
	(obj._e[eventName] ?= []).push listener, group, isOnce
	obj.emit 'newListener', {eventName: eventName, listener: listener, group: group, isOnce: isOnce}
	return
# CLASS
class EventEmitter
	constructor: ->
		# store event listeners
		# as: eventName: [listener, group, isOnce, ...]
		@_e= _create null # store events
		return
	###*
	 * Convert plain objects ito event emitters
	###
	@apply: (plainObj)->
		_defineProperty plainObj, '_e', value: _create null
		_defineProperties plainObj, Object.getOwnPropertyDescriptors EventEmitter.prototype
		return
	###*
	 * Add event
	###
	on: (eventName, listener, isOnce)->
		throw new Error 'Expected two args' unless arguments.length is 2
		_eventEmitterAddListener this, eventName, listener, no
		this # chain
	###*
	 * Once
	###
	once: (eventName, listener)->
		throw new Error 'Expected two args' unless arguments.length is 2
		_eventEmitterAddListener this, eventName, listener, yes
		this # chain
	###*
	 * Remove event
	###
	off: (eventName, listener)->
		try
			throw 'Illegl arguments' if arguments.length > 2
			throw 'Event expected string' unless typeof eventName is 'string'
			queue= @_e
			# get group
			if typeof eventName is 'string'
				idx= eventName.indexOf '.'
				if idx is -1
					group= null
				else
					group= (eventName.substr idx+1) or null
					eventName= eventName.substr 0, idx
				eventName = eventName.toLowerCase()
			# do
			switch arguments.length
				# remove all events
				when 0
					for k of queue
						_eventEmitterEmitRemove this, k, queue[k]
						delete queue[k]
				# ::off(eventName)
				# ::off(listener)
				when 1
					if typeof eventName is 'string'
						# remove
						if group
							rmFx= (q, i)-> q[i+1] is group
							if eventName
								_eventEmitterClean this, eventName, queue[eventName], rmFx
							else
								for k of queue
									_eventEmitterClean this, k, queue[k], rmFx
						else if eventName
							_eventEmitterEmitRemove this, eventName, queue[eventName]
							delete queue[eventName]
					else if typeof eventName is 'function'
						listener= eventName
						rmFx= (q, i)-> q[i] is listener
						for k of queue
							_eventEmitterClean this, k, queue[k], rmFx
					else
						throw 'Illegal arguments'
				# ::off(eventName, listener)
				when 2
					throw 'EventName expected string' unless typeof eventName is 'string'
					throw 'listener expected function' unless typeof listener is 'function'
					if group
						rmFx= (q, i)-> (q[i] is listener) and (q[i+1] is group)
						if eventName
							_eventEmitterClean this, eventName, queue[eventName], rmFx
						else
							for k of queue
								_eventEmitterClean this, k, queue[k], rmFx
					else
						_eventEmitterClean this, eventName, queue[eventName], (q, i)-> q[i] is listener
				else
					throw 'Illegal arguments'
		catch err
			err= new Error "EventEmitter::off>> #{err}" if typeof err is 'string'
			throw err
		this # chain
	###*
	 * Emit event
	 * @promise
	###
	emit: (eventName)->
		throw new Error 'Expected event Name' unless typeof eventName is 'string'
		throw new Error 'Event name must have no "dot"' unless ~eventName.indexOf '.'
		eventName = eventName.toLowerCase()
		if queue= @_e[eventName]
			args= [].slice.call arguments, 1
			# executor
			execFx= (listener)=>
				setTimeout (=>
					try
						# call listener
						listener.apply this, args
					catch err
						if event is 'error'
							Core.fatalError 'errorHandlers', err
						else
							@emit 'error', err
					return
				), 0
			# loop
			len= queue.length
			i=0
			while i < len
				listener= queue[i]
				# remove if is once
				if queue[i+2]
					ar= queue.slice i, 3
					_eventEmitterEmitRemove this, eventName, ar
					len= queue.length
				else
					i+= 3
				# exec
				execFx listener
		return
	###*
	 * eventNames
	###
	eventNames: -> Object.keys @_e
	###*
	 * Listeners
	###
	listeners: (eventName)->
		list= []
		switch arguments.length
			when 0
				for k,queue of @_e
					len= queue.length
					i=0
					while i<len
						list.push queue[i]
						i+= 3
			when 1
				eventName = eventName.toLowerCase()
				if queue= @_e[eventName]
					len= queue.length
					i=0
					while i<len
						list.push queue[i]
						i+= 3
			else
				throw new Error 'Illegal arguments'
		return list

# interface
_defineProperty Core, 'EventEmitter', value: EventEmitter