###*
 * Date picker component
###
Core.component 'date-picker', class extends Component
	constructor: (element)->
		super(element)
		# Init values
		attrs= @getAttributes()
		min= attrs.min
		min= if min then @_fixDate min else -Infinity
		max= attrs.max
		max= if max then @_fixDate max else Infinity
		# Private properties
		properties=
			name:		attrs.name
			class:		attrs.class
			min:		min
			max:		max
			pattern:	null
			value:		null
			currentDate: null
			views:		null
			startView:	null
			currentView:null
			# flags
			readonly: !!attrs.readonly
			weeks:	!!attrs.weeks
			keep:	!!attrs.keep
			type:	null
		@_properties= properties
		@_enabled= no
		# Format
		@setPattern attrs.pattern or 'date'
		@setType attrs.type or 'simple'
		@setValue attrs.value or new Date()
		# Render function
		@htmlRender= Core.html.datePicker
		# Do render
		super.render()
		@_enabled= yes
		return

	_fixDate: (date)->
		if typeof date is 'number'
			result= date
		else if typeof date is 'string'
			result= new Date date
			if isNaN result.getDate()
				date= +date
				throw new Error 'Invalid date' if isNaN(date)
				result= new Date date
		else
			throw new Error 'Invalid date'	
		return result
	setMin: (min)->
		@_properties.min= @_fixDate min
		@render() #chain
	getMin: -> @_properties.min
	setMax: (min)->
		@_properties.max= @_fixDate max
		return @render() #chain
	getMax: -> @_properties.max

	###* FORMAT ###
	setPattern: (format)->
		throw new Error 'Illegal arguments' unless arguments.length is 1 and typeof format is 'string'
		# Compile format
		@_properties.pattern= compileDatePattern format
		return @_prepareVisibleViews()
	getPattern: -> @_properties.pattern
	###* Select visible views ###
	_prepareVisibleViews: ()->
		# filter reduced patterns
		properties= @_properties
		format= properties.pattern
		reducedPatterns= []
		for p in format.patterns
			p= p.charAt(0).toLowerCase()
			reducedPatterns.push p unless p in reducedPatterns
		# Visible views
		parentView= null
		if 'y' in reducedPatterns
			lastChild= parentView= parent: parentView, child: null, name: 'years'
			startView= parentView
		if reducedPatterns.some (el)-> el in ['m', 'd']
			parentView= parent: parentView, child: null, name: 'months'
			lastChild= parentView= parent: parentView, child: null, name: 'days'
			startView= parentView
		if reducedPatterns.some (el)-> el in ['h', 'i', 's']
			lastChild= parentView= parent: parentView, child: null, name: 'time'
			startView?= parentView
		# Complete view chain
		throw new Error "Illegal date format" unless lastChild
		while parentView= lastChild.parent
			parentView.child= lastChild
			lastChild= parentView
		# save
		properties.startView= startView
		properties.currentView= startView
		return
	###* TYPE ###
	setType: (type)->
		throw new Error "Illegal type: #{type}" unless type in ['simple', 'multiple', 'range']
		@_properties.type= type
		return @render()
	getType: -> @_properties.type
	###* Set value ###
	setValue: (value)->
		# Fix value
		if typeof value is 'string'
			value= value.split ','
			for v, i in value
				v2= new Date(v)
				if isNaN v2.getDate()
					v2= +v
					if isNaN v2
						throw new Error "Illegal date: #{v}"
					else
						v2= new Date(v2)
				value[i]= v2
		else if typeof value is 'number'
			value=[new Date(value)]
		else if value instanceof Date
			value= [value]
		else throw new Error 'Illegal value'
		# Set value
		@_properties.value= value
		@_properties.currentDate= value[0]
		# Reload component
		return @render()
	###* RENDER ###
	render: ->
		super.render @_properties if @_enabled
		this # chain

	###* CHANGE VIEW ###
	_goToView: (element, transition)->
		# create next month
		properties= @_properties
		currentView= properties.currentView
		currentDate= properties.currentDate
		# fix current view
		switch transition
			when 'up'
				pv= currentView.parent
			when 'down'
				pv= currentView.child
			else
				pv= currentView
				# Next date
				isNext= transition is 'next'
				inc= if isNext then 1 else -1
				switch currentView.name
					when 'years'
						currentDate.setYear currentDate.getFullYear() + if isNext then 6 else -6
					when 'months'
						currentDate.setYear currentDate.getFullYear() + inc
					when 'days'
						currentDate.setMonth currentDate.getMonth() + inc
					when 'time'
						currentDate.setDate currentDate.getDate() + inc
					else
						throw new Error "Unimplemented type: #{currentView.name}"
		throw new Error 'Illegal operation' unless pv
		currentView= properties.currentView= pv

		# Create days view
		switch currentView.name
			when 'years'
				view= Core.html.datePickerYears properties
			when 'months'
				view= Core.html.datePickerMonths properties
			when 'days'
				view= Core.html.datePickerDays properties
			when 'time'
				view= Core.html.datePickerTime properties
			else
				throw new Error "Unimplemented type: #{currentView.name}"
		view= _toHTMLElement view

		# append
		container= element.closest('.date-picker-container')
		oldView= container.firstChild
		container.appendChild view
		anim= "anim-#{transition}"
		$container= $(container)
		$container
			.addClass(anim)
			.animationOnce ->
				$container.removeClass(anim)
				container.removeChild oldView
				return
		return

	###* Actions ###
	# Next view
	go: (event, args)-> @_goToView event.currentTarget, args[1]
	# Select value
	select: (event, args)->
		element= event.currentTarget
		value= parseInt args[1]
		properties= @_properties
		currentView= properties.currentView
		# set value
		dateValue= properties.value[0] # For now, we support only one selected date
		currentDate= properties.currentDate
		switch currentView.name
			when 'years'
				dateValue.setYear value
				currentDate.setYear value
			when 'months'
				dateValue.setMonth value
				currentDate.setMonth value
			when 'days'
				dateValue.setDate value
				currentDate.setDate value
			# when 'time'
			else
				throw new Error "Unimplemented type: #{currentView.name}"
		# Change parent controller
		#TODO
		# Go to next view or trigger close
		if currentView.child
			@_goToView element, 'down'
		return



