### validation custom callbacks ###
V_CUSTOM_CB= _create null
Core.vCb= (cbName, cb)->
	throw new Error "Illegal arguments" unless arguments.length is 2 and typeof cbName is 'string' and typeof cb is 'function'
	throw new Error "Validation callback already set: #{cbName}" if V_CUSTOM_CB[cbName]
	V_CUSTOM_CB[cbName]= cb
	this # chain
### form validation ###
#=include _validations.coffee
#=include _watches.coffee