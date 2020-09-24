###*
 * DOM compile date
 * datetime: date-time
 * d-pattern: date pattern
 * d-relaed: show a relaxed version if near date
###
Core.init (parent)->
	# Check relaxed dates
	relaxedDates= parent.querySelectorAll('.core-time[d-relaxed]')
	if relaxedDates.length
		element.classList.remove 'core-time' for element in relaxedDates
		Core.htmlDateRelaxed(relaxedDates)
	# Check for normal dates
	for element in parent.querySelectorAll '.core-time'
		try
			element.classList.remove 'core-time'
			pattern= element.getAttribute('d-pattern') or 'full'
			value= element.getAttribute('datetime') or element.getAttribute('d-datetime')
			continue unless value
			# Convert to date
			if isNaN data
				date= new Date(value)
			else
				date= new Date(parseInt value)
			throw new Error "Illegal date: #{value}" if isNaN date.getDate()
			# if input
			if element.tagName is 'INPUT'
				element.value= _dateCache.upsert(pattern).format date
			else
				element.innerHTML= _dateCache.upsert(pattern).format date
		catch err
			Core.fatalError 'Date-formater', err
	return
