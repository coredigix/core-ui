
###* TYPE VALIDATION ###
vType: (value, element, param)->
	param= param.trim()
	return value unless param
	for tp in param.toLowerCase().split /[\s,]+/
		tp= "type_#{tp}"
		fx= @[tp]
		throw new Error "Unknown method: #{tp}" unless typeof fx is 'function'
		return value if fx.call this, value, element
	throw no

###*
 * TYPES
###
type_empty: (value)-> !value
type_email: (data)-> EMAIL_REGEX.test data
type_tel: (data)-> TEL_REGEX.test data

type_url: (data)->
	try
		new URL data
	catch err
		return false
	return true

# numbers
type_number: (data)-> not isNaN(+data)
type_hex: (data)-> HEX_REGEX.test data
