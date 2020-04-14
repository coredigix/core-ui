###*
 * Capitalize
###
capitalizeSnakeCase: (str, delimeter='-')->
	if str
		str= str.replace /^[\s-_]+|[\s-_]+$/g, ''
			.replace /[\s-_]+(\w)/g, (_, w)-> delimeter + w.toUpperCase()
		str= str.charAt(0).toUpperCase() + str.substr 1
	return str

# EMAIL
EMAIL_REGEX: EMAIL_REGEX

# TEL
TEL_REGEX:	TEL_REGEX