###*
 * Tabs
###
Core.addAction 'click', 'tabs', (event)->
	$this= $ this
	# CHECK IF TABS ALREADY INITIALIZED
	if $this.hasClass 'tabs-enabled'
		tabBar= this.querySelector '.tabs-bar'
		barStyle= tabBar.style
	else
		$this.addClass 'tabs-enabled'
		# add tab bar
		tabBar= document.createElement 'div'
		tabBar.className= 'tabs-bar'
		# Apply style
		if activeTab= @querySelector('.tab.active')
			barStyle= tabBar.style
			barStyle.width= "#{activeTab.offsetWidth}px"
			barStyle.left= "#{activeTab.offsetLeft}px"
		@appendChild tabBar
	# ENABLE CLICKED TAB
	if activeTab= event.realTarget.closest '.tab'
		$activeTab= $(activeTab)
		$activeTab.addClass('active').siblings('.active').removeClass('active')
		barStyle.width= "#{activeTab.offsetWidth}px"
		barStyle.left= "#{activeTab.offsetLeft}px"
		# Show tab body
		$this.siblings('.tabs-body').children().eq($activeTab.index()).addClass('active').siblings('.active').removeClass('active')
	return