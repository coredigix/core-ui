### Interface ###
_coreWatcher= new _Watcher()

_defineProperties Core,
	Watcher: value: _Watcher
	EventWrapper: value: EventWrapper

	watch:	value: ->
		_coreWatcher._watch arguments, false
		this # chain
	watchSync: value: ->
		_coreWatcher._watch arguments, true
		this # chain
	unwatch: value: ->
		_coreWatcher._unwatch arguments, false
		this
	unwatchSync: value: ->
		_coreWatcher._unwatch arguments, true
		this

	# addEvent
	addEvent: value: (eventName, nativeEventName, listenerGenerator) ->
		_coreWatcher.addEvent eventName, nativeEventName, listenerGenerator
		this # chain

	# Add action
	addAction: value: ->
		_coreWatcher._addAction arguments, false
		this # chain
	addActionSync: value: ->
		_coreWatcher._addAction arguments, true
		this # chain
	removeAction: value: ->
		_coreWatcher._removeAction arguments, false
		this # chain
	removeActionSync: value: ->
		_coreWatcher._removeAction arguments, true
		this # chain







