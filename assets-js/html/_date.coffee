# date utils
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


# format Date
Core.formatDate= (date, format)->
	_fixedDigit = (n)-> if n < 10 then '0' + n else n
	format.replace /\$(.)/gi, (_, key)->
		switch key
			when 'y' then date.getYear().toString().substr(1)
			when 'Y' then date.getFullYear()
			when 'm' then _fixedDigit date.getMonth() + 1 # month
			when 'M' then i18n.months[date.getMonth()] # month name
			when 'n' then i18n.monthsAbrv[date.getMonth()] # month name
			when 'd' then _fixedDigit date.getDate()
			when 'D' then i18n.days[date.getDay()]
			when 'e' then i18n.daysAbrv[date.getDay()]
			when 'H' then _fixedDigit date.getHours()
			when 'h'
				h= date.getHours()
				if h >= 13 then h-= 12
				_fixedDigit h
			when 'i' then _fixedDigit date.getMinutes()
			when 's' then _fixedDigit date.getSeconds()
			when 'S' then _fixedDigit date.getMilliseconds()
			when 't'
				h = date.getHours()
				if h >= 12 then 'pm'
				else 'am'
			when 'T'
				h = date.getHours()
				if h >= 12 then 'PM'
				else 'AM'
			when 'z' then date.getTimezoneOffset()
			when 'Z' then date.getTimezoneOffset() / 60
			else key
# relaxed date
Core.relaxedDate= _relaxedDate= (date, currentDate, midnightDate)->
	# current date
	currentDate?= new Date()
	midnightDate?= new Date currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()
	# parse date
	if typeof date is 'string'
		date= parseInt date if /^[0-9]+$/.test date
		date= new Date date
	# format
	range = (currentDate - date) / 1000
	end= no
	if range < 180	# less then 3min
		value= i18n.justNow
	else if range < 3600 # less then 60min
		value= i18n.$min count: Math.round range / 60
	else if date > midnightDate
		value= i18n.$h count: Math.round range / 3600
	else if midnightDate - date < 24 * 3600 * 1000
		value= Date.format date, i18n.$yesterday
	else if currentDate.getFullYear() is date.getFullYear()
		value= Date.format date, i18n.$thisYear
	else
		value= Date.format date, i18n.$fullDate
		end= yes
	# return
	end: end
	value: value

# date process
_dateProcessInterval= null
_dateProcessRun= ->
	# process date
	len= _dateProcessFormat document
	# stop if len is null
	unless len
		clearInterval _dateProcessInterval
		_dateProcessInterval= null
	return
_dateProcess= (container)->
	# process date
	len= _dateProcessFormat container or document
	# run interval
	if len and not _dateProcessInterval
		_dateProcessInterval= setInterval _dateProcessRun, 60000
	return
_dateProcessFormat= (container)->
	elements = container.querySelectorAll 'time[datetime]:not(.time-fixed)'
	if len= elements.length
		for element in elements
			v = _relaxedDate element.getAttribute 'datetime'
			element.innerText = v.value
			if v.end
				element.classList.add 'time-fixed'
	return len