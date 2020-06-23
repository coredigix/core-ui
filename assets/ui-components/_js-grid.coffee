###*
 * Interactive grid
###
# DEFAULT CELL OPTIONS
GRID_DEFAULT=
	col: '50px'
	gap: '10px'
	resize: 5 # 10px
	colMax: 255
	rowMax: 255
GRID_DEFAULT_CELL=
	colSpan: 1
	rowSpan: 1
# Resize cursors
GRID_RESIZE_CURSORS=
	R:	'e-resize'	# RIGHT
	BR:	'se-resize'	# BOTTOM-RIGHT
	B:	's-resize'	# BOTTOM
JS_GRID_ITEM= Symbol 'Grid-item'
# COMPONENT
Core.component 'js-grid', class extends Component
	constructor: (element)->
		super(element)
		@_enabled= true
		element.classList.add '_js-grid'
		# Resizing blocks
		if resize= element.getAttribute('d-resize')
			resize= parseInt resize
			resize= GRID_DEFAULT.resize if isNaN resize
		else
			resize= GRID_DEFAULT.resize
		# Load values
		col= element.getAttribute('d-col') or GRID_DEFAULT.col
		gap= element.getAttribute('d-gap') or GRID_DEFAULT.gap
		min= parseInt element.getAttribute('d-min')
		min= 0 if isNaN min
		options=
			col: col
			row: element.getAttribute('d-row') or col
			colGap: element.getAttribute('d-col-gap') or gap
			rowGap: element.getAttribute('d-row-gap') or gap
			# max
			colMax: element.getAttribute('d-col-max') or GRID_DEFAULT.colMax
			rowMax: element.getAttribute('d-row-max') or GRID_DEFAULT.rowMax
			# Other options
			resize: resize
			# Min size before applying grid
			min:  min
		@_properties= options
		# Event listeners
		@_resizeEffect= @_resizeEffect.bind this
		@_mouseDown= @_mouseDown.bind(this)
		# Adjust style
		@setOptions options
		return
	### window resize ###
	onWindowResize: (event)->
		super(event)
		@_adjustView()
		return
	_adjustView: ->
		element= @element
		elementStyle= element.style
		if element.offsetWidth < @_properties.min
			@_enabled= no
			element.classList.remove '_js-grid'
		else
			@_enabled= yes
			element.classList.add '_js-grid'
		@_enableEvents @_enabled
		return

	###* SET OPTIONS ###
	setOptions: (options)->
		# Options
		options= _assign @_properties, options
		# Resize
		vl= options.resize
		options.resize= 0 unless typeof vl is 'number' and vl > 0
		vl= parseInt options.min
		options.min= if isNaN(vl) then 0 else vl
		element= @element
		elementStyle= element.style
		# Check the size
		@_adjustView()
		# row and col
		elementStyle.gridTemplateColumns= "repeat(auto-fill, minmax(#{options.col}, 1fr))"
		elementStyle.gridAutoRows= options.row
		# Gap
		elementStyle.columnGap= elementStyle.gridColumnGap= options.colGap
		elementStyle.rowGap= elementStyle.gridRowGap= options.rowGap
		# Enable events
		@_enableEvents @_enabled
		# Adjust items
		@reload()
		# Chain
		this
	###* Reload items ###
	reload: ->
		element= @element
		if element.childElementCount
			frag= document.createDocumentFragment()
			frag.appendChild el while el= element.firstChild
			@append frag
		this # chain
	###* GET ALL ITEMS DATA ###
	getData: ->
		items= []
		for el in @element.children
			items.push el[JS_GRID_ITEM] or _assign({}, GRID_DEFAULT_CELL)
		# Return
		return items: items
	###* Push new items ###
	append: (item, itemData)->
		throw new Error 'Illegal arguments' unless arguments.length in [1, 2] and item
		itemData= [itemData] unless _isArray itemData
		# Fragement
		frag= document.createDocumentFragment()
		frag.appendChild item # Accept html elements or document fragment
		# Add private values
		for child, i in frag.children
			try
				if data= itemData[i]
					# do nothing more
				else if data= child.getAttribute 'd-grid'
					data= JSON.parse data
				# assign default options
				data= _assign {}, GRID_DEFAULT_CELL, data
				# Set data
				childStyle= child.style
				childStyle.gridColumn= "auto / span #{data.colSpan}"
				childStyle.gridRow= "auto / span #{data.rowSpan}"
				child[JS_GRID_ITEM]= data
			catch err
				@emit 'error', err
		# Push frag
		@element.appendChild frag
		this # chain
	###* @private get resize area ###
	_resizeArea: (target, event)->
		# CHECK IF CURSOR IS IN THE RESIZE ZONE
		resizeMarge= @_properties.resize
		resizeArea= null
		# Item bounds
		bounds= target.getBoundingClientRect()
		isInBottom= event.y > bounds.y + bounds.height - resizeMarge
		if event.x > bounds.x + bounds.width - resizeMarge
			if isInBottom then resizeArea= 'BR'
			else resizeArea= 'R'
		else if isInBottom
			resizeArea= 'B'
		return resizeArea
	###* @private Move event ###
	_enableEvents: (doEnable)->
		element= @element
		listenersOpts= {capture: no, passive: yes}
		element.removeEventListener 'mousemove', @_resizeEffect, listenersOpts
		element.removeEventListener 'mousedown', @_mouseDown, listenersOpts
		if doEnable
			if @_properties.resize
				element.addEventListener 'mousemove', @_resizeEffect, listenersOpts
			element.addEventListener 'mousedown', @_mouseDown, listenersOpts
		this # chain
	_resizeEffect: (event)->
		# Check if show resize
		element= @element
		target= event.target
		unless target is element
			# Get closest target
			target= target.parentNode while target.parentNode isnt element
			# Check for area
			st= target.style
			if resizeArea= @_resizeArea(target, event)
				st.cursor= GRID_RESIZE_CURSORS[resizeArea]
			else
				st.removeProperty('cursor')
		return
	###* @private mousedown event listener ###
	_mouseDown: (event)->
		# options
		options= @_properties
		element= @element
		target= event.target
		return if target is element
		# parse options
		cellWidth= parseInt(options.col) + parseInt(options.colGap)
		cellHeight= parseInt(options.row) + parseInt(options.rowGap)
		return if isNaN(cellWidth) or isNaN(cellHeight)
		return unless cellWidth>0 and cellHeight>0
		# Get closest target to grid element
		target= nt while (nt= target.parentNode) isnt element
		listenerOpts= {capture: no, passive: yes}
		hasChanges= no
		
		# RESIZE
		if resizeArea= @_resizeArea(target, event)
			# Resize effect
			originalWidth= target.offsetWidth
			originalHeight= target.offsetHeight
			resizeEffect= _toHTMLElement Core.html.gridPlaceholder
				style:
					width: "#{originalWidth}px"
					height: "#{originalHeight}px"
			target.classList.add '_grid-ph'
			target.appendChild resizeEffect
			# Listeners
			originalX= event.x
			originalY= event.y
			colSize= options.col + options.colGap
			resizeListener= (event)->
				hasChanges= yes
				w= if resizeArea is 'B' then originalWidth else originalWidth + event.x - originalX
				h= if resizeArea is 'R' then originalHeight else originalHeight + event.y - originalY
				st= resizeEffect.style
				st.width= "#{w}px"
				st.height= "#{h}px"
				# Blocks count
				colSpan= Math.min (Math.round w/cellWidth), options.colMax
				rowSpan= Math.min (Math.round h/cellHeight), options.rowMax
				st= target.style
				st.gridColumn= "auto / span #{colSpan}"
				st.gridRow= "auto / span #{rowSpan}"
				# Save data
				data= target[JS_GRID_ITEM] ?= _assign {}, GRID_DEFAULT_CELL
				data.colSpan= colSpan
				data.rowSpan= rowSpan
				return
			mouseUpListener= (event)=>
				document.removeEventListener 'mousemove', resizeListener, listenerOpts
				document.removeEventListener 'mouseup', mouseUpListener, listenerOpts
				target.removeChild resizeEffect
				target.classList.remove '_grid-ph'
				# Trigger changers
				if hasChanges
					data= target[JS_GRID_ITEM]
					@emit 'change', {type: 'resize', item: target, data: data}
					target[COMPONENT_SYMB]?.emit 'resize', data: data
				return
			document.addEventListener 'mousemove', resizeListener, listenerOpts
			document.addEventListener 'mouseup', mouseUpListener, listenerOpts

		# MOVE
		else if moveEl= event.target.closest '.grid-move'
			currentIndex= $(target).index()
			# Original values
			offsetParent= target.offsetParent
			originalX= event.x
			originalY= event.y
			originalTop= target.offsetTop
			originalLeft= target.offsetLeft
			# place holder
			moveEffect= _toHTMLElement Core.html.gridPlaceholder
				style:
					top: "#{originalTop}px"
					left: "#{originalLeft}px"
					width: "#{target.offsetWidth}px"
					height: "#{target.offsetHeight}px"
			offsetParent.appendChild moveEffect
			element.classList.add '_grid-moving'
			target.classList.add '_grid-mv'
			# Disable resize
			@_enableEvents no
			# Listeners
			moveListener= (event)->
				dx= event.x - originalX
				dy= event.y - originalY
				st= moveEffect.style
				st.top= "#{originalTop + dy}px"
				st.left= "#{originalLeft + dx}px"
				# Check for next target
				nwTarget= event.target
				return if nwTarget is element
				nt= nwTarget
				while nt isnt element
					nwTarget= nt
					return unless nt= nwTarget.parentNode # outside current grid
				return if nwTarget is target
				# move element
				bound= nwTarget.getBoundingClientRect()
				nwTx= bound.x + bound.width/2
				x= event.x
				if x<nwTx
					element.insertBefore target, nwTarget
				else if nxtEl= nwTarget.nextElementSibling
					element.insertBefore target, nxtEl
				else
					element.appendChild target
				return
			mouseUpListener= (event)=>
				document.removeEventListener 'mousemove', moveListener, listenerOpts
				document.removeEventListener 'mouseup', mouseUpListener, listenerOpts
				offsetParent.removeChild moveEffect
				@_enableEvents yes # renable resize if set
				element.classList.remove '_grid-moving'
				target.classList.remove '_grid-mv'
				# Trigger changes
				newIndex= $(target).index()
				if newIndex isnt currentIndex
					@emit 'change',
						type: 'sort'
						item: target
						data: target[JS_GRID_ITEM]
						oldIndex: currentIndex
						newIndex: newIndex
				return
			document.addEventListener 'mousemove', moveListener, listenerOpts
			document.addEventListener 'mouseup', mouseUpListener, listenerOpts
		return










