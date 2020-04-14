###*
 * Files utils
###

###* Convert text to bytes ###
toBytes: do ->
	units=
		'':	1
		b:	1		# Byte
		k:	2**10	# kiloByte
		m:	2**20	# megaByte
		g:	2**30	# gigaByte
		t:	2**40	# teraByte
		p:	2**50	# petaByte
		e:	2**60	# exaByte
		z:	2**70	# zettaByte
		y:	2**80	# yottaByte
	parseRegex= /^\s*(\d+)\s*([a-z])?b?\s*$/i
	return (value)->
		if typeof value is 'string'
			parts= parseRegex.exec value
			if parts
				mult= units[parts[2].toLowerCase()]
				if mult?
					value= parseFloat(parts[1]) * mult
				else
					value= null
			else
				value= null
		else unless typeof value is 'number'
			value= null
		return value