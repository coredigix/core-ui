###*
 * Dispatch custom event
###
dispatch: (eventName, event, target, isSync)->
	# Generate eventPath
	eventPath= []
	element= target
	currentElement= @element
	while element and element isnt currentElement
		eventPath.push element
		element= element.parentNode
	# Dispatch Actions
	@_dispatch eventName, event, target, eventPath, isSync, null
	# Chain
	this

###* @private dispatch ###
_dispatch: (eventName, event, target, eventPath, isSync, prevArgs)->
	# attribute name
	actionAttribute= if isSync then "d-#{eventName}-sync" else "d-#{eventName}"
	# CSS watchers
	cssWatchers= if isSync then @_watchSync[eventName] else @_watch[eventName]
	# Disaptch this event
	for element in eventPath
		# Action args
		actionArgs= element.getAttribute actionAttribute
		continue unless actionArgs or cssWatchers
		# Wrap event
		wrappedEvent= new EventWrapper eventName, event, element, target, isSync
		# ACTIONS
		if actionArgs
			try
				# Split to get args
				actionArgs= actionArgs.trim().split /\s+/
				# action= actionArgs[0].toLowerCase()
				action= actionArgs[0]
				throw "Unknown action: #{action}" unless typeof @[action] is 'function'
				# Add previous call args
				if prevArgs
					actionArgs= prevArgs.concat actionArgs
					action= actionArgs[0]
				# Run
				@[action] wrappedEvent, actionArgs
			catch err
				@emit 'error', err
		# CSS SELECTORS: [cssSelector, handler, ...]
		if cssWatchers
			i= 0
			len= cssWatchers.length
			while i<len
				selector= cssWatchers[i++]
				handlerName= cssWatchers[i++]
				if element.matches selector
					try
						if prevArgs
							args= prevArgs.concat handlerName
							handlerName= prevArgs[0]
						else
							args= [handlerName]
						if typeof handlerName is 'function'
							handlerName.call this, wrappedEvent, args
						else
							throw "Unknown handler [#{handlerName}] for watch: #{selector}" unless typeof @[handlerName] is 'function'
							@[handlerName] wrappedEvent, args
						# break if stop immediate bubbles
						break unless wrappedEvent.bubblesImmediate
					catch err
						@emit 'error', err
		# BREAK IF STOP_PROPAGATION IS CALLED
		break unless wrappedEvent.bubbles
	# Disaptch linked events
	# _linkEvents= {eventName: [customEvnt1, ...]}
	if linkEvents= @_linkEvents[eventName]
		for customEvntName in linkEvents
			nArgs= [customEvntName]
			nArgs= nArgs.contact prevArgs if prevArgs
			@dispatch customEvntName, event, target, eventPath, isSync, nArgs
	return
