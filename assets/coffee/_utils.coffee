###*
 * OBJECT
###
_create=					Object.create
_assign=					Object.assign
_keys=						Object.keys
_defineProperty=			Object.defineProperty
_defineProperties=			Object.defineProperties
_getOwnPropertyDescriptor=	Object.getOwnPropertyDescriptor
_getOwnPropertyDescriptors=	Object.getOwnPropertyDescriptors

# Array
_isArray= Array.isArray
_isStrArray= (arr)->
	return false unless _isArray
	for el in arr
		return false unless typeof el is 'string'
	return true

