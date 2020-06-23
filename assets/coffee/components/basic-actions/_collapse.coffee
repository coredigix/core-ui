###*
 * Collapse
###
collapse: (event, args)->
	if head= event.realTarget.closest('.collapse-head')
		$head= $(head)
		$nextBody= $head.next('.collapse-body')
		collapseType= args[1]
		# Check if close others
		if collapseType is 'toggle'
			$head.siblings('.collapse-head').removeClass 'active'
			$nextBody.siblings('.collapse-body').slideUp('fast')
		# Toggle current collapse item
		if head.classList.toggle 'active'
			$nextBody.slideDown('fast')
		else
			$nextBody.slideUp('fast')
	return