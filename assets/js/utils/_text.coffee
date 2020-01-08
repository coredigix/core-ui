_capitalizeSnakeCase= (str, delimeter='-')->
	if str
		str= str.replace /^[\s-_]+|[\s-_]+$/g, ''
			.replace /[\s-_]+(\w)/g, (_, w)-> delimeter + w.toUpperCase()
		str= str.charAt(0).toUpperCase() + str.substr 1
	return str
###*
 * Email
###
EMAIL_REGEX= /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
TEL_REGEX= /^[0+][\d\s-]{5,}$/
###*
 * Interface
###
_defineProperties Core,
	capitalizeSnakeCase: value: _capitalizeSnakeCase
	EMAIL_REGEX: value: EMAIL_REGEX
	TEL_REGEX: value: TEL_REGEX

