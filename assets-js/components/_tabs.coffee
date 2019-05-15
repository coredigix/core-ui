# tabs
# open tabs
Core.addAction 'click', 'openTab', (event)->
	tab= event.target.closest '.tab'
	return if not tab or tab.classList.contains 'active'
	tabHeader= tab.parentNode
	$tabHeader= $(tabHeader)
	$prev= $tabHeader.find('>.active').removeClass('active')
	tab.classList.add 'active'
	# move indicator
	$tabHeader.find('>.tab-indicator').css
		width: tab.offsetWidth
		left: tab.offsetLeft
	# trigger change event
	$tabHeader.closest('.tabs').trigger 'tab-change',
		tab: tab
		previous: $prev[0]
	return
# adjust indicator
_adjustTabIndicator= (container)->
	for indicator in container.querySelectorAll '.tab-indicator'
		$parent= $ indicator.parentNode
		activeTab= $parent.find('>.tab.active')[0]
		activeTab?= $parent.find('>.tab')[0]
		if activeTab
			indicatorStyle= indicator.style
			indicatorStyle.width= activeTab.offsetWidth + 'px'
			indicatorStyle.left= activeTab.offsetLeft + 'px'
			indicatorStyle.display= 'block'
	return