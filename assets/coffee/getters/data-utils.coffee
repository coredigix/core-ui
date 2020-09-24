# week of year
unless Date::hasOwnProperty 'getWeekOfYear'
	Date::getWeekofYear = ->
		d		= new Date Date.UTC @getFullYear(), @getMonth(), @getDate()
		dayNum	= d.getUTCDay() || 7
		d.setUTCDate d.getUTCDate() + 4 - dayNum
		yearStart = new Date Date.UTC d.getUTCFullYear(), 0, 1
		Math.ceil (((d - yearStart) / 86400000) + 1) / 7
# week of month
unless Date::hasOwnProperty 'getWeekOfMonth'
	Date::getWeekOfMonth= ->
		d= new Date @getFullYear(), @getMonth(), 1
		Math.ceil (d.getDay() + @getDate()) / 7
# day of year
unless Date::hasOwnProperty 'getDayOfYear'
	Date::getDayOfYear	= ->
		d	= new Date @getFullYear(), 0, 0
		Math.floor (this - d) / 86400000
# now
unless Date.now
	Date.now	= -> new Date().getTime()