###*
 * Date picker component
###
Core.component 'range', class extends Component
	constructor: (element)->
		super(element)
		# Init values
		attrs= @getAttributes()
		max= _safeNumber attrs.max, 100
		min= _safeNumber attrs.min, 0
		max= min + 1 if max <= min
		step= _safeNumber attrs.step, 0
		step= 0 if step<0
		value= _safeNumber attrs.value, min
		
		# Set private attributes
		properties= @_properties=
			name: attrs.name
			class: attrs.class
			max: max
			min: min
			step:step
			value: value
			track:null
			originalTrack: null # used on caret drag
			tmp: null # used on move event
		@_calcValue value
		@_calcTrack()
		# Render function
		@htmlRender= Core.html.inputRange
		# do render
		super.render properties
		return
	setMax: (value)->
		throw new Error "Illegal max value" unless typeof value is 'number' and Number.isFinite(value)
		properties= @_properties
		properties.max= value
		@setValue properties.value
	setMin: (value)->
		throw new Error "Illegal min value" unless typeof value is 'number' and Number.isFinite(value)
		properties= @_properties
		properties.min= value
		@setValue properties.value
	setStep: (value)->
		value=0 if value is 'any'
		throw new Error "Illegal step value" unless typeof value is 'number' and value isnt Infinity and value>=0
		properties= @_properties
		properties.step= value
		super.render properties
		this
	# Set value
	_calcValue: (value)->
		# properties
		properties= @_properties
		step= properties.step
		min= properties.min
		max= properties.max
		# range
		if value < min
			value= min
		else if value > max
			value= max
		# Steper
		value= step * Math.round((value-min)/step) + min if step > 0
		properties.value= value
		return value
	_calcTrack: ->
		properties= @_properties
		min= properties.min
		max= properties.max
		properties.track= properties.originalTrack= (properties.value-min)*100 / (max-min)
	_setValue: (value)->
		properties= @_properties
		# setValue
		properties.value= value
		# save
		element= @element
		element.querySelector('input').value= value
		element.querySelector('.track').style.width= "#{properties.track}%"
		return
	setValue: (value)->
		throw new Error "Illegal min value" unless typeof value is 'number' and Number.isFinite(value)
		# calc value
		@_calcValue value
		@_calcTrack()
		# render
		@_setValue value
		this # chain


	getMax: -> @_properties.max
	getMin: -> @_properties.min
	getStep: -> @_properties.step

	# Events
	# CLICK on track
	select: (event, args)->
		# calc clicked position
		target= event.currentTarget
		bound= target.getBoundingClientRect()
		p= Math.round((event.originalEvent.x - bound.x)*100*16/(bound.width or 1))/16
		if p<0 then p=0
		else if p>100 then p=100
		# value
		properties= @_properties
		properties.track= p
		properties.originalTrack= p
		value= @_calcValue p*(properties.max-properties.min)/100 + properties.min
		@_calcTrack()
		@_setValue value
		return
	# Movestart
	drag: (event, args)->
		target= event.currentTarget
		properties= @_properties
		switch event.type
			when 'movestart'
				properties.tmp= targetclosest('.progress').getBoundingClientRect().width
				@element.classList.add 'no-anim'
			when 'move'
				p= properties.originalTrack + (event.x - event.originalX)*100/properties.tmp
				if p<0 then p=0
				else if p>100 then p=100
				properties.track= p
				value= @_calcValue p*(properties.max-properties.min)/100 + properties.min
				@_setValue value
			when 'moveend'
				@element.classList.remove 'no-anim'
				@_calcTrack()
				@_setValue properties.value
			else
				throw new Error 'Illegal use'
		return

#TODO add multi value choose range (not regular step)
#TODO add vertical range
#TODO add range choose
#TODO add circular range
#TODO link range to input number