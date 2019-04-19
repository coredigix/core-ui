### Save actions to be executed ###
ACTIONS= _create null
	# click: _create null
# Add watch
_addActionDes= (k)->
	CORE_REACTOR.watch "[d-#{k}]",
		[k]: (event)->
			a= @getAttribute 'd-' + k
			unless cb= ACTIONS[k][a]
				throw new Error "Unknown action #{k}.#{a}"
			cb.call this, event
# define actions
_defineProperties Core,
	###*
	 * Add actions
	 * @param {String}   name - action attribute
	 * @param {Function} cb   - callback to execute
	###
	addAction: value: (eventName, name, cb)->
		throw new Error 'Illegal arguments' unless arguments.length is 3 and typeof eventName is 'string' and typeof name is 'string' and typeof cb is 'function'
		unless q= ACTIONS[eventName]
			q= ACTIONS[eventName]= _create null
			_addActionDes eventName
		throw new Error "Action already set: #{eventName}.#{name}" if q[name]
		q[name]= cb
		this # chain
	removeAction: value: (eventName, name)->
		throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof eventName is 'string' and typeof name is 'string'
		q= ACTIONS[eventName]
		delete q[name] if q
		this # chain
# utils
_hasElement= (event, element)->
	el= event.target
	while el
		return true if el is element
		el= el.parentNode
	return false
# fist matched
_firstMatch= (event, selector)->
	el= event.target
	while el and el isnt document
		if el.matches selector
			return el
		el= el.parentNode
	return false

### BASIC ACTIONS ###
#= include _form-actions.coffee
#= include _dropdown.coffee