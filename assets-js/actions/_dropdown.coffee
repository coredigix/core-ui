# Symbols
DROPDOWN_VALUE= Symbol 'dropdown-value'
DROPDOWN_XHR= Symbol 'dropdown-xhr' # when loading data from server (must have an "abort" method)
# default dropdown handler
DEFAULT_DROPDOWN_HANDLER=
	# data: async function(hint){} # function: will return data to show based on hint (autocomplete)
	# Render item value, default to a simple text value
	renderItem: (item, dropdown)-> item
	renderResult: (item, dropdown)-> item
	closeOnSelect: yes # close when an item is selected
	toggle: yes # toggle close and open when clicking on value
	hideValue: no # hide value box when openning dropdown
	multiple: no # is multichoice dropdown
	resultSet: yes # when multiple, do not duplicate result add (prevent selected from showing when possible)
	# effective stored value
	# value: (selected)-> selected.id
	###*
	 * Value serialization to be send 
	 * @return {String} - serialized value
	###
	value: (selected)-> selected
	# events
	# onSelect: (ele)->
	# onChange: (ele)->
DEFAULT_MULTI_CHOICE_DROPDOWN_HANDLER=
	multiple: true
	renderResult: (item)-> item
_setPrototypeOf DEFAULT_MULTI_CHOICE_DROPDOWN_HANDLER, DEFAULT_DROPDOWN_HANDLER

DROPDOWN_DESCRIPTORS= _create null

# default dropdown data function
_dropdownData= -> this
_dropdownDataStr= (hint)-> @filter (el)-> el.indexOf(hint) >= 0

# get dropdown descritor
_getDropdownDescriptor= (dropdown)->
	attr= dropdown.getAttribute 'd-dropdown'
	return DROPDOWN_DESCRIPTORS[attr] or DEFAULT_DROPDOWN_HANDLER

# add dropdown descriptor
_defineProperties Core,
	addDropdown: value: (name, descriptor)->
		try
			# check
			throw 'Expected two args' unless arguments.length is 2
			throw 'name expected string' unless typeof name is 'string'
			throw 'descriptor expected plain object' unless typeof descriptor is 'object' and descriptor
			throw 'Already set: ' + name if DROPDOWN_DESCRIPTORS[name]
			# check data
			data= descriptor.data
			if data
				unless typeof data is 'function'
					throw new Error 'data expected function or items array' unless Array.isArray data
					if data.every (e)-> typeof e is 'string'
						descriptor.data= _dropdownDataStr.bind data
					else
						descriptor.data= _dropdownData.bind data
			# prototype
			_setPrototypeOf descriptor, if descriptor.multiple then DEFAULT_MULTI_CHOICE_DROPDOWN_HANDLER else DEFAULT_DROPDOWN_HANDLER
			# add
			DROPDOWN_DESCRIPTORS[name]= descriptor
		catch err
			err= new Error 'Dropdown>> ' + err if typeof err is 'string'
			throw err
	removeDropdown: value: (name)->
		delete DROPDOWN_DESCRIPTORS[name]
		this # chain
# eventify objecy
# EventEmitter.apply DEFAULT_DROPDOWN_HANDLER
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
_dropdown_next= (nxt)->
	$nxt= $ '.dropdown-hover', currentDropDown
		.removeClass('dropdown-hover')[nxt]()
	$nxt= $ '.dropdown-item:' + (if nxt is 'next' then 'first' else 'last'), currentDropDown unless $nxt.length
	$nxt.addClass 'dropdown-hover'
	# scroll
	# $pop= $nxt.closest '.dropdown-popup'
	#TODO
	return
# remove dropdown value (when multichoise)
_rmDropDownValue= (dropdown, value)->
	arr= dropdown[DROPDOWN_VALUE]
	# remove in array
	if arr
		for el, i in arr
			if el is value
				arr.splice i, 1
				break
	# remove in DOM
	for el in $ '.dropdown-value:first>*', dropdown
		if el[DROPDOWN_VALUE] is value
			$(el).remove()
			break
	return
# wrap multiple result (when multiple dropdown)
_dropdownWrapMulti= (vl, value, dropdown)->
	rs= document.createElement 'div'
	rs.className= 'dropdown-vl'
	rs[DROPDOWN_VALUE]= value
	# add content
	if typeof vl is 'string'
		rs.innerHTML= vl
	else 
		rs.appendChild vl
	# add close
	close= document.createElement 'i'
	close.className= 'ico close'
	close.innerHTML= 'close'
	rs.appendChild close
	close.addEventListener 'click', (event)-> _rmDropDownValue dropdown, value
	return rs
# item select
_dropdownSelect= (item)->
	descriptor= _getDropdownDescriptor currentDropDown
	value= item[DROPDOWN_VALUE] or item.innerHTML
	# render
	$vl= $('.dropdown-value:first', currentDropDown)
	addDOM= !!$vl.length # flag
	# autocomplete format
	if $vl.is 'input'
		$vl.val descriptor.value value
	# multiple choice
	else
		isMultiple= descriptor.multiple
		isResultSet= descriptor.resultSet
		if isMultiple
			arr= currentDropDown[DROPDOWN_VALUE] ?= []
			if isResultSet and value in arr
				addDOM= no
			else
				arr.push value
		# select format
		else
			$vl.empty()
			currentDropDown[DROPDOWN_VALUE]= value
			
		# render value
		if addDOM
			vl= descriptor.renderResult value, currentDropDown
			if isMultiple
				$vl.append _dropdownWrapMulti vl, value, currentDropDown
			else if vl is 'string'
				$vl.html vl
			else
				$vl.append vl
			# fill nested input
			$('.dropdown-box input:first', currentDropDown).val descriptor.value value
	# do close
	_dropdownStop() if descriptor.closeOnSelect
	return
# drop down render items
_dropDownRenderItems= ->
	dropdown= currentDropDown
	descriptor= _getDropdownDescriptor dropdown
	# has data to render. Other wise static data from HTML
	if data= descriptor.data
		$dropdown= $ dropdown
		try
			# loading
			$dropdown.addClass 'loading'
			# load items
			hint= $dropdown.find('>.dropdown-box input, >.dropdown-popup>.f-cntrl input').val()
			data= data hint
			if ld instanceof Promise
				dropdown[DROPDOWN_XHR]?.abort?() # abort previous call
				dropdown[DROPDOWN_XHR]= data # save new call
				data= await data
				# check still active
				return unless dropdown is currentDropDown
			# render items
			frag= document.createDocumentFragment()
			if data
				throw new Error 'Expected array as result of loading data' unless Array.isArray data
				for item in data
					# render
					li= descriptor.renderItem item, dropdown
					# wrap
					if li and li.tagName is 'LI'
						li.classList.append '.dropdown-item'
					else
						wli= document.createElement 'li'
						wli.className= '.dropdown-item.p-tiny'
						if typeof li is 'string'
							wli.innerHTML= li
						else
							wli.appendChild li
						li= wli
					# value
					li[DROPDOWN_VALUE]= item
					# append to fragment
					frag.appendChild li
			# insert frag
			$dropdown.find '.dropdown-items'
				.empty()
				.append frag
				.find '>.dropdown-item: first'
				.addClass 'dropdown-hover' # select first element
		catch err
			err= new Error 'dropdown-renderItems>>' + err if typeof err is 'string'
			throw err
		finally
			$dropdown.removeClass 'loading'
	return
# mouseout
_dropdownOut= (event)->
	unless _hasElement event, currentDropDown
		currentDropDownHover= no
	return
# keyboard listener
_dropdownKeyboardListener= (event)->
	k= event.keyCode or event.which
	switch k
		when 27 # Escape
			_dropdownStop event
			event.preventDefault()
		when 38 # Up
			event.preventDefault()
			_dropdown_next 'prev'
		when 40 # down
			event.preventDefault()
			_dropdown_next 'next'
		when 13 # enter
			_dropdownSelect currentDropDown.querySelector '.dropdown-hover'
			event.preventDefault()
	return
# dropdown click
_dropdownClick= (event)->
	# click inside
	if _hasElement event, currentDropDown
		# click on item
		if item= _firstMatch event, '.dropdown-item'
			_dropdownSelect item
		# close if toggle click
		else if (_getDropdownDescriptor currentDropDown).toggle and _firstMatch event, '.dropdown-box'
			_dropdownStop event
	# click outside
	else
		_dropdownStop event
	return
# Stop drop down
_dropdownStop= (e)->
	# skip if event is "scroll" and currentDropDownHover
	if currentDropDownHover and e and e.type is 'scroll'
		return
	# stop
	dropdown= currentDropDown
	dropdown[DROPDOWN_XHR]?.abort?() # abort xhr call
	currentDropDown= null
	$(dropdown).removeClass 'dropdown-open dropdown-up dropdown-down'
	# remove listeners
	dropdown.removeEventListener 'mouseover', _dropdownHover, true
	# document listeners
	document.removeEventListener 'mouseover', _dropdownOut, true
	document.removeEventListener 'click', _dropdownClick, true
	document.removeEventListener 'scroll', _dropdownStop, true
	# window listeners
	window.removeEventListener 'resize', _dropdownStop, true
	window.removeEventListener 'keydown', _dropdownKeyboardListener, false
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
			dpopupSize= clientHeight - bounds.top - bounds.height
			if bounds.top > dpopupSize
				dpopupSize= bounds.top - 10
				if popupSize > dpopupSize
					$popup.css height: dpopupSize
				$dropdown.addClass 'dropdown-up'
			else
				$popup.css height: dpopupSize - 10
				$dropdown.addClass 'dropdown-down'
	# open dropdown
	$dropdown.addClass 'dropdown-open'
	currentDropDownHover= yes
	# $dropdown.addClass 'dropdown-up'
	# add hover event
	dropdown.addEventListener 'mouseover', _dropdownHover, _dropdownListenerOptions
	# document listeners
	document.addEventListener 'mouseover', _dropdownOut, _dropdownListenerOptions
	document.addEventListener 'click', _dropdownClick, _dropdownListenerOptions
	document.addEventListener 'scroll', _dropdownStop, _dropdownListenerOptions
	# add keyboard listener
	window.addEventListener 'resize', _dropdownStop, _dropdownListenerOptions
	window.addEventListener 'keydown', _dropdownKeyboardListener, false
	# if autocomplete, select first input
	$popup.find('>.f-cntrl>input').focus().select()
	# init items
	_dropDownRenderItems()
	return
# drop down
CORE_REACTOR.watch '.dropdown-box',
	click: (event)->
		$this= $ this
		return if _firstMatch event, '.dropdown-vl'
		$dropdown= $this.closest '.dropdown'
		if $dropdown.hasClass 'dropdown-open'
			_dropdownStop()
		else
			_dropdownStart $dropdown
		return