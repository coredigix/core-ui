###*
 * Date utils
###
_defineProperties Core,
	# return formated date
	toLocalDate: value: (date)->
		if typeof date is 'number'
			date= new Date(date)
		else unless date instanceof Date
			throw new Error "Expected date as argument"
		"#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear()}  #{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}.#{date.getMilliseconds()}"