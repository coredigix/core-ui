###
# UTILITIES
###

###*
 * Stopable promise
###
# _Promise= ->
# 	resolve= null
# 	reject= null
# 	new Promise (resolve, reject)->

### STRING ###
_capitalizeSnakeCase= (str, delimeter='-')->
	if str
		str= str.replace /^[\s-_]+|[\s-_]+$/g, ''
			.replace /[\s-_]+(\w)/g, (_, w)-> delimeter + w.toUpperCase()
		str= str.charAt(0).toUpperCase() + str.substr 1
	return str

_defineProperties Core,
	### STRING ###
	capitalizeSnakeCase: value: _capitalizeSnakeCase
	###*
	 * get Page Base URL
	###
	baseURL:
		configurable: true
		get: ->
			b= document.getElementsByTagName 'base'
			b= b[0]?.href or document.location.href
			_defineProperty this, 'baseURL', value: b
			return b
	###*
	 * Promisefy timeout
	 * @param {Number} timeout - timeout in ms
	 * @optional @param {Mixed} resolvedValue	- value to resolve or reject if delay not stoped
	 * @optional @param {Boolean} doResolve - when false, will call reject instead of resolve with specified value
	###
	delay: value: (timeout, resolvedValue, doResolve)->
		resolve= null
		reject= null
		# promise
		p = new Promise (res, rej)->
			resolve= res
			reject= rej
			return
		# timeout
		timeoutP= setTimeout (->
			if doResolve is false
				reject resolvedValue
			else
				resolve resolvedValue
			return
		), timeout
		return
		# add explicite resolve and reject
		_defineProperties p,
			resolve: value: (vl)->
				clearTimeout timeoutP
				resolve vl
				return
			reject: value: (vl)->
				clearTimeout timeoutP
				reject vl
				return
		# return
		return p