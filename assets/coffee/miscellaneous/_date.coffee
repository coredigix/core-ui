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
 * Date relaxed
###
dateRelaxed: (date, relativeDate)->
	# i18n
	throw new Error "Expected i18n.datePatterns.relaxed function" unless i18n? and (i18nDatePatterns=i18n.datePatterns) and typeof i18nDatePatterns.relaxed is 'function'
	# Relative date
	relativeDate= Date.now() unless relativeDate?
	relativeMidnight= relativeDate - ( relativeDate % (1000 * 3600 * 24) )
	# Exec
	# Prepare
	targetTime = if typeof date is 'number' then date else date.getTime()
	# Calc
	range= ~~((relativeDate - targetTime) / 1000)
	return i18nDatePatterns.relaxed range, date
htmlDateRelaxed: do ->
	_ELEMENT_CLASS= '_core-dt-mng_'
	_ELEMENT_SELECTOR= '.'+ _ELEMENT_CLASS
	_interv= null
	_exec= (htmlElements)->
		# Relative Date
		relativeDate= Date.now()
		relativeMidnight= relativeDate - ( relativeDate % (1000 * 3600 * 24) )
		i18nDatePatterns= i18n.datePatterns
		for element in htmlElements
			try
				# Prepare
				continue unless date= element.getAttribute 'datetime'
				targetTime = if isNaN(date) then (new Date(date)).getTime() else parseInt date
				# Calc
				range= ~~((relativeDate - targetTime) / 1000)
				value= i18nDatePatterns.relaxed range, targetTime, relativeMidnight
				isntFinal= value isnt false
				unless isntFinal
					# Set finale value
					pattern= element.getAttribute('d-pattern') or 'full'
					value= _dateCache.upsert(pattern).format new Date targetTime
				element.innerHTML= value
				element.classList.toggle _ELEMENT_CLASS, isntFinal
			catch error
				Core.fatalError 'CORE', error
		return
	_intervExec= ->
		elements= document.querySelectorAll _ELEMENT_SELECTOR
		if elements.length then _exec elements
		else
			clearInterval _interv
			_interv= null
		return
	return (htmlElements, relativeDate)->
		# i18n
		throw new Error "Expected i18n.datePatterns.relaxed function" unless i18n? and (i18nDatePatterns=i18n.datePatterns) and typeof i18nDatePatterns.relaxed is 'function'
		# Exec
		htmlElements= [htmlElements] unless typeof htmlElements.length is 'number'
		_exec htmlElements
		# Start _interv
		_interv= setInterval _intervExec, 60000 unless _interv
		return
