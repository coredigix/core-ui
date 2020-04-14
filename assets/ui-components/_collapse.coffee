###*
 * Collapse
###
ROOT_COMPONENT.addAction 'click', 'collapse', (event)->
	collapseType= @getAttribute 'd-type'
	if head= event.realTarget.closest('.collapse-head')
		$head= $(head)
		$nextBody= $head.next('.collapse-body')
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