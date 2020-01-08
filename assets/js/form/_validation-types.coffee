###*
 * Validation types
###
TYPE_OPERATIONS=
	empty: (value)-> !value
	email: (data)-> EMAIL_REGEX.test data
	tel: (data)-> TEL_REGEX.test data

	url: (data)->
		try
			new URL data
		catch err
			return false
		return true
	password: (data)-> 6 <= data.length <= 100

	# numbers
	number: (data)->
		data= +data
		if isNaN(data)
			return false
		return value: data
	'>0': (data)->
		data= +data
		if isNaN(data) or data<=0
			return false
		return value: data
	'>=0': (data)->
		data= +data
		if isNaN(data) or data<0
			return false
		return value: data
	'<0': (data)->
		data= +data
		if isNaN(data) or data>=0
			return false
		return value: data
	'<=0': (data)->
		data= +data
		if isNaN(data) or data>0
			return false
		return value: data
