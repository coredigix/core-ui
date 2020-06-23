###*
 * DOM compile date
 * datetime: date-time
 * d-pattern: date pattern
 * d-relaed: show a relaxed version if near date
###
Core.init (parent)->
	# Check for dates to compile
	for element in parent.querySelectorAll '.core-time'
		try
			element.classList.remove 'core-time'
			pattern= element.getAttribute('d-pattern') or 'full'
			value= element.getAttribute('datetime') or element.getAttribute('d-datetime')
			continue unless value
			date= new Date(value)
			if isNaN date.getDate()
				date= new Date(parseInt value)
				throw new Error "Illegal date: #{value}" if isNaN date.getDate()
			# if input
			if element.tagName is 'INPUT'
				element.value= _dateCache.upsert(pattern).format date
			else
				# Check if do relaxed date
				if element.hasAttribute 'd-relaxed'
					console.log 'Unimplemented'
				# Show formated date
				element.innerHTML= _dateCache.upsert(pattern).format date
		catch err
			Core.fatalError 'Date-formater', err
	return

