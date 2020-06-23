###*
 * Event watchers
 * ::_watch={
 * 		eventName: [cssSelector, handlerName, ...]
 * }
 *
 * @example
 * Component.watch 'cssSelector', { click: 'handlerName', hover: 'handlerName' }
###

###* Async watch ###
@watch: (cssSelector, options)-> @_watchEvent cssSelector, options, no
@watchSync: (cssSelector, options)-> @_watchEvent cssSelector, options, yes
@_watchEvent: (cssSelector, options, isSync)->
	try
		# Checks
		throw 'Illegal css-selector' unless typeof cssSelector is 'string'
		throw 'Illegal arguments' unless typeof options is 'object' and options?
		# convert options to array
		kies= _keys(options)
		values= []
		for eventName in kies
			v= options[eventName]
			values.push v
			unless typeof v is 'string' or typeof v is 'function'
				throw "Expected handler name as string or function for: #{eventName}. Selector: #{cssSelector}"
		# Get this class and it's subclasses
		classes= COMPONENTS_MAP_CHILDS.get(this)
		# Add each event
		for cl in classes
			wEvnt= if isSync then cl.prototype._watchSync else cl.prototype._watch
			for eventName,i in kies
				(wEvnt[eventName]?= []).push cssSelector, values[i]
		# Enbale events
		@_enableNativeEvent kies, isSync
	catch err
		err= new Error "::watch>> #{err}" if typeof err is 'string'
		throw err
	this # chain


