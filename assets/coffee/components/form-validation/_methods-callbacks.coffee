###*
 * Compare input values
###
inputEquals: (value, input, args)->
	throw false unless input.form[args[1]].value is value
	return value