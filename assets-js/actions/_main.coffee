### Save actions to be executed ###
ACTIONS=
	click: _create null
# define actions
_defineProperties Core,
	###*
	 * Add actions
	 * @param {String}   name - action attribute
	 * @param {Function} cb   - callback to execute
	###
	addAction: value: (eventName, name, cb)->
		throw new Error 'Illegal arguments' unless arguments.length is 3 and typeof eventName is 'string' and typeof name is 'string' and typeof cb is 'function'
		q= ACTIONS[eventName]
		throw new Error "Unsupported action: #{eventName}" unless q
		throw new Error "Action already set: #{eventName}.#{name}" if q[name]
		q[name]= cb
		this # chain
	removeAction: value: (eventName, name)->
		throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof eventName is 'string' and typeof name is 'string'
		q= ACTIONS[eventName]
		delete q[name] if q
		this # chain

# Add watch
_addActionDes= (k)->
	CORE_REACTOR.watch "[d-#{k}]",
		[k]: (event)->
			unless cb= ACTIONS[k][@getAttribute 'd-' + k]
				throw new Error "Unknown action #{k}.#{a}"
			cb.call this, event
_addActionDes k for k of ACTIONS


### BASIC ACTIONS ###
#= include _form-actions.coffee