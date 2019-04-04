
# dropdown item hover
_dropdownListenerOptions=
	capture: true
	passive: true
currentDropDown= null # current active dropdown
currentDropDownHover= false # do current drop down is hovered. Used to close when scroll or not
_dropdownHover= (event)->
	currentDropDownHover= yes
	# check for dropdown item
	ele= event.target
	while ele and ele isnt document
		if ele.classList.contains 'dropdown-item'
			$ ele
				.addClass 'dropdown-hover'
				.siblings '.dropdown-hover'
				.removeClass 'dropdown-hover'
			break
		ele= ele.parentNode
	return
# mouseout
_dropdownOut= (event)->
	unless _hasElement event, currentDropDown
		currentDropDownHover= no
	return
# keyboard listener
_dropdownKeyboardListener= (event)->
	k= event.keyCode or event.which
	if k is 27 # Escape
		_dropdownStop event
	else if k is 38 # Up
		# up
	else if k is 40 # Down
		# down
	return
# Stop drop down
_dropdownStop= (e)->
	# skip if event is "scroll" and currentDropDownHover
	if currentDropDownHover and e and e.type is 'scroll'
		return
	# stop
	dropdown= currentDropDown
	currentDropDown= null
	$(dropdown).removeClass 'dropdown-open dropdown-up dropdown-down'
	# remove listeners
	dropdown.removeEventListener 'mouseover', _dropdownHover, true
	# document listeners
	document.removeEventListener 'mouseover', _dropdownOut, true
	document.removeEventListener 'click', _dropdownStop, true
	document.removeEventListener 'scroll', _dropdownStop, true
	# window listeners
	window.removeEventListener 'resize', _dropdownStop, true
	window.removeEventListener 'keyup', _dropdownKeyboardListener, true

	return
# dropdown fx
_dropdownStart= ($dropdown)->
	# close previous drop down
	_dropdownStop() if currentDropDown
	currentDropDown= dropdown= $dropdown.get 0
	clientWidth= window.innerWidth
	clientHeight= window.innerHeight
	# clientWidth= document.body.clientWidth
	$popup= $dropdown.find('.dropdown-popup:first').css(height:'')
	if clientWidth <= MOBILE_WIDTH
		# mobile
	else
		# get dropdown size
		$dropdown.addClass 'dropdown-open'
		throw new Error 'Illegal dropdown' unless $popup.length is 1
		popupSize= $popup.height()
		$dropdown.removeClass 'dropdown-open'
		# open drop down
		bounds= dropdown.getBoundingClientRect()
		if popupSize + bounds.top <= clientHeight
			$dropdown.addClass 'dropdown-down'
		else
			popupSize= clientHeight - bounds.top - bounds.height
			if bounds.top > popupSize
				$popup.css height: bounds.top - 10
				$dropdown.addClass 'dropdown-up'
			else
				$popup.css height: popupSize - 10
				$dropdown.addClass 'dropdown-down'
	# open dropdown
	$dropdown.addClass 'dropdown-open'
	currentDropDownHover= yes
	# $dropdown.addClass 'dropdown-up'
	# add hover event
	dropdown.addEventListener 'mouseover', _dropdownHover, _dropdownListenerOptions
	# document listeners
	document.addEventListener 'mouseover', _dropdownOut, _dropdownListenerOptions
	document.addEventListener 'click', _dropdownStop, _dropdownListenerOptions
	document.addEventListener 'scroll', _dropdownStop, _dropdownListenerOptions
	# add keyboard listener
	window.addEventListener 'resize', _dropdownStop, _dropdownListenerOptions
	window.addEventListener 'keyup', _dropdownKeyboardListener, _dropdownListenerOptions
	return
# drop down
CORE_REACTOR.watch '.dropdown-value',
	click: (event)->
		$dropdown= $(this).closest '.dropdown'
		if $dropdown.hasClass 'dropdown-open'
			_dropdownStop()
		else
			_dropdownStart $dropdown
		return