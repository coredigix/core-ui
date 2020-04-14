###*
 * Event emitter
###
EventEmitter= do ->
	EVENT_QUEUE= Symbol 'Event Queue'
	###*
	 * Add event listeners
	###
	_on= (obj, isOnce, eventName, listener)->
		throw new Error 'EventEmitter::on>> Event listener expected function'
		if typeof eventName is 'string'
			eventName= eventName.trim().split /\s+/
		throw new Error 'Illegal event name' unless _isStrArray eventName
		_addListener obj, isOnce, el, listener for el in eventName
		return
	_addListener= (obj, isOnce, eventName, listener)->
		# Check no space
		throw new Error 'EventEmitter::on>> Event name contains space' if /\s/.test eventName
		# add queue
		queue= obj[EVENT_QUEUE]?= new Map()
		# Group
		idx= eventName.indexOf '.'
		if ~idx
			group= (eventName.substr idx+1) or null
			eventName= eventName.substr 0, idx
		else
			group= null
		# Check event name isnt an empty string
		throw new Error 'Event name is null' unless eventName
		eventName= eventName.toLowerCase()
		# add
		unless eventQ= queue.get eventName
			queue= []
			queue.set eventName, queue
		queue.push listener, group, isOnce
		# obj.emit '_listenerAdded',
		# 	eventName: eventName,
		# 	listener: listener
		# 	group: group
		# 	isOnce: isOnce
		return

	# Remove events
	_eventEmitterClean= (queue, eventName, fxRemover)->
		if q= queue.get(eventName)
			i= 0
			len= q.length
			while i<len
				if fxRemover q, i
					q.splice i, 3
					len= q.length
				else
					i+= 3
		return
	# INTERFACE
	return class EventEmitter
		constructor: ->
		###*
		 * Convert plain objects ito event emitters
		###
		@apply: (plainObj)->
			_defineProperties plainObj, _getOwnPropertyDescriptors @prototype
			return plainObj

		###*
		 * Add event
		 * @param {String, Array[String]} eventName - name of the event, could be grouped by '.'
		 * @param {function} listener - The listener
		###
		on: (eventName, listener)->
			throw new Error 'EventEmitter::on>> Expected two args' unless arguments.length is 2
			_on this, no, eventName, listener
			this # chain
		###*
		 * Once
		 * @param {String, Array[String]} eventName - name of the event, could be grouped by '.'
		 * @param {function} listener - The listener
		###
		once: (eventName, listener)->
			throw new Error 'EventEmitter::once>> Expected two args' unless arguments.length is 2
			_on this, yes, eventName, listener
			this # chain
		###*
		 * Remove event
		###
		off: (eventName, listener)->
			try
				throw 'Illegal arguments' if arguments.length > 2
				throw 'Event expected string' unless typeof eventName is 'string'
				queue= @[EVENT_QUEUE]
				return this unless queue
				# get group
				if typeof eventName is 'string'
					idx= eventName.indexOf '.'
					if ~idx
						group= (eventName.substr idx+1) or null
						eventName= eventName.substr 0, idx
					else
						group= null
					eventName= eventName.toLowerCase()
				# Do
				switch arguments.length
					# remove all events
					when 0
						queue.clear()
					# ::off(eventName)
					# ::off(listener)
					when 1
						# ::off(eventName)
						if typeof eventName is 'string'
							if group
								strGrp= "#{group}."
								fxRemover= (q,i)->
									grp= q[i+1]
									return grp is group or grp.startsWith(strGrp)
								if eventName
									_eventEmitterClean queue, eventName, fxRemover
								else
									queue.forEach (v,k)-> _eventEmitterClean queue, k, fxRemover
							else
								queue.delete eventName
						# ::off(listener)
						else if typeof eventName is 'function'
							listener= eventName
							fxRemover= (q,i)-> q[i] is listener
							queue.forEach (v,k)-> _eventEmitterClean queue, k, fxRemover
						else
							throw 'Illegal arguments'
					# ::off(eventName, listener)
					when 2
						throw 'EventName expected string' unless typeof eventName is 'string'
						throw 'listener expected function' unless typeof listener is 'function'
						if group
							strGrp= "#{group}."
							fxRemover= (q,i)->
								grp= q[i+1]
								return (q[i] is listener) and (grp is group or grp.startsWith(strGrp))
							if eventName
								_eventEmitterClean queue, eventName, fxRemover
							else
								queue.forEach (v,k)-> _eventEmitterClean queue, k, fxRemover
						else
							fxRemover= (q,i)-> q[i] is listener
							_eventEmitterClean queue, eventName, fxRemover
					else
						throw 'Illegal arguments'
			catch err
				err= new Error "EventEmitter::off>> #{err}" if typeof err is 'string'
				throw err
			this # chain
		###*
		 * Emit event
		###
		emit: (eventName)->
			throw new Error 'Expected event name' unless typeof eventName is 'string'
			throw new Error "Event name contains group: #{eventName}" if ~eventName.indexOf '.'
			eventName= eventName.toLowerCase()
			if q= @[EVENT_QUEUE]?.get eventName
				args= [].slice.call arguments, 1
				# executor
				execFx= (listener)=>
					setTimeout (=>
						try
							listener.apply this, args
						catch err
							if event is 'error'
								Core.fatalError 'errorHandlers', err
							else
								@emit 'error', err
						return
					), 0
					return
				# Loop
				len= queue.length
				i=0
				while i < len
					listener= queue[i]
					# remove if is once
					if queue[i+2]
						ar= queue.slice i, 3
						len= queue.length
					else
						i+= 3
					# exec
					execFx listener
			else if eventName is 'error'
				Core.fatalError 'Emitter',
					message: 'Uncaught error'
					args: [].slice.call arguments, 1
			this # chain
		###*
		 * eventNames
		###
		eventNames: -> if @[EVENT_QUEUE]? then _keys @[EVENT_QUEUE] else []
		
		###*
		 * Listeners
		###
		listeners: (eventName)->
			throw new Error 'Expected event name' unless typeof eventName is 'string'
			throw new Error "Event name contains group: #{eventName}" if ~eventName.indexOf '.'
			eventName= eventName.toLowerCase()
			result= []
			return result unless queue= @[EVENT_QUEUE]
			_loadEvent= (q)->
				i= 0
				len= q.length
				while i<len
					result.push q[i]
					i+= 3
				return
			switch arguments.length
				when 0
					queue.forEach _loadEvent
				when 1
					_loadEvent q if q= queue.get eventName
			return result
		###*
		 * Check has event name
		###
		hasEvent: (eventName)->
			throw new Error 'Expected string as event name' unless typeof eventName is 'string'
			throw new Error "Event name contains group: #{eventName}" if ~eventName.indexOf '.'
			if q= @[EVENT_QUEUE] then q.has eventName.toLowerCase() else no
		hasListener: (eventName, listener)->
			throw new Error 'Expected string as event name' unless typeof eventName is 'string'
			if queue= @[EVENT_QUEUE]
				# Group
				idx= eventName.indexOf '.'
				if ~idx
					group= (eventName.substr idx+1) or null
					eventName= eventName.substr 0, idx
				else
					group= null
				eventName= eventName.toLowerCase()
				# check
				if q= queue.get eventName
					i= 0
					len= q.length
					if group
						strGrp= "#{group}."
						while i < len
							grp= q[i+1]
							if q[i] is listener and (grp is group or grp.startsWith(strGrp))
								return yes
							i+= 3
					else
						while i < len
							return yes if q[i] is listener
							i+= 3
			return no