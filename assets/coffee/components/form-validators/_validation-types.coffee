###*
 * Validation types for "v-type"
 * ::vType(value, element, component)
###
empty: (value)-> !value
email: (data)-> EMAIL_REGEX.test data
tel: (data)-> TEL_REGEX.test data

url: (data)->
	try
		new URL data
	catch err
		return false
	return true

# numbers
number: (data)-> not isNaN(+data)
hex: (data)-> HEX_REGEX.test data