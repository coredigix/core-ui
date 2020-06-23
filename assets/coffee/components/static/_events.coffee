 ###*
 * Link events
 * @example
 * ::linkEvent('hover', 'mouseover')
###
@linkEvent: (customEvent, srcEvent)->
	try
		throw 'Illegal arguments' unless arguments.length is 2 and typeof customEvent is 'string' and typeof srcEvent is 'string'
		throw 'Could not link event to it self' if customEvent is srcEvent
		customEvent= customEvent.toLowerCase()
		srcEvent= srcEvent.toLowerCase()
		throw 'Illegal event name' unless EVENT_NAME_REGEX.test(customEvent) and EVENT_NAME_REGEX.test(srcEvent)
		throw "Custom event already linked: #{customEvent}" if @prototype._customEvents[customEvent]
		# Get this class and it's subclasses
		classes= COMPONENTS_MAP_CHILDS.get(this)
		for cl in classes
			clPrototype= cl.prototype
			# Check not already defined this custom event
			if (srcEv= clPrototype._customEvents[customEvent]) and srcEv isnt srcEvent
				throw "A subClass already linked [#{customEvent}] to [#{srcEv}]"
			# Add
			clPrototype._customEvents[customEvent]= srcEvent
			arr= clPrototype._linkEvents[srcEvent]?= []
			arr.push customEvent unless customEvent in arr
	catch err
		err= new Error "::linkEvent>> #{err}" if typeof err is 'string'
		throw err
	this # chain
	