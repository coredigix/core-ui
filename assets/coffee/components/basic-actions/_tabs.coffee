###*
 * Tabs
 * @example
 * 		d-click="tabs"
###
tabs: (event, args)->
	container= event.currentTarget
	$container= $ container
	# CHECK IF TABS ALREADY INITIALIZED
	if $container.hasClass 'tabs-enabled'
		tabBar= container.querySelector '.tabs-bar'
		barStyle= tabBar.style
	else
		$container.addClass 'tabs-enabled'
		# add tab bar
		tabBar= document.createElement 'div'
		tabBar.className= 'tabs-bar'
		# Apply style
		if activeTab= container.querySelector('.tab.active')
			barStyle= tabBar.style
			barStyle.width= "#{activeTab.offsetWidth}px"
			barStyle.left= "#{activeTab.offsetLeft}px"
		container.appendChild tabBar
	# ENABLE CLICKED TAB
	if activeTab= event.realTarget.closest '.tab'
		$activeTab= $(activeTab)
		$activeTab.addClass('active').siblings('.active').removeClass('active')
		barStyle.width= "#{activeTab.offsetWidth}px"
		barStyle.left= "#{activeTab.offsetLeft}px"
		# Show tab body
		$container.siblings('.tabs-item').addClass('h').eq($activeTab.index()).removeClass('h')
		# @DEPRECATED
		$container.siblings('.tabs-body').children().eq($activeTab.index()).addClass('active').siblings('.active').removeClass('active')
	return
