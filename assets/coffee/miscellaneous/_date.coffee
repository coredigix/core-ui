###*
 * Return formated date
 * TODO: add correct format depending on locale
###
formatDate: (date, pattern)->
	throw new Error "Expected pattern to be string" unless typeof pattern is 'string'
	return _dateCache.upsert(pattern).format date

###* Get week of year ###
getWeekOfYear: (date)->
	try
		d		= new Date Date.UTC date.getFullYear(), date.getMonth(), date.getDate()
		dayNum	= d.getUTCDay() || 7
		d.setUTCDate d.getUTCDate() + 4 - dayNum
		yearStart = new Date Date.UTC d.getUTCFullYear(), 0, 1
		return Math.ceil (((d - yearStart) / 86400000) + 1) / 7
	catch err
		throw err if date instanceof Date
		date= new Date(date)
		throw new Error 'Invalid date' if isNaN date.getFullYear()
		return @getWeekOfYear date
###* Week of month ###
getWeekOfMonth: (date)->
	try
		d= new Date date.getFullYear(), date.getMonth(), 1
		Math.ceil (d.getDay() + date.getDate()) / 7
	catch err
		throw err if date instanceof Date
		date= new Date(date)
		throw new Error 'Invalid date' if isNaN date.getFullYear()
		return @getWeekOfMonth date

###* Day of year ###
getDayOfYear: (date)->
	try
		d	= new Date date.getFullYear(), 0, 0
		Math.floor (this - d) / 86400000
	catch err
		throw err if date instanceof Date
		date= new Date(date)
		throw new Error 'Invalid date' if isNaN date.getFullYear()
		return @getDayOfYear date

###* Compile date format ###
compileDatePattern: compileDatePattern

# Date patterns
datePatterns: do ->
	throw new Error "Expected: i18n.datePatterns" unless patterns= i18n.datePatterns
	# Return
	date:		compileDatePattern patterns.date
	monthYear:	compileDatePattern patterns.monthYear
	shortDate:	compileDatePattern patterns.shortDate


###*
 * Date patterns cache
###