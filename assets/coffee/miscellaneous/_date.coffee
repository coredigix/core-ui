###*
 * Return formated date
 * TODO: add correct format depending on locale
###
formateDate: (date)->
	# Checks
	throw new Error 'Illegal arguments' unless arguments.length is 1
	# Convert
	if typeof date is 'number'
		date= new Date(date)
	else unless date instanceof Date
		throw new Error 'Expected a valide date'
	"#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear()}  #{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}.#{date.getMilliseconds()}"
