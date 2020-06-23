###*
 * SUBMIT
 * @example
 * d-click="submit"		submit closest form
 * d-click="submit #form" submit selected form
###
submit: (event, args)->
	# Get form
	form= if args.length>1 then @element.querySelector(args.slice(1).join(' ')) else event.currentTarget.closest 'form'
	if form
		@_onSubmit
			target: form
			preventDefault: ->
	return

###*
 * Text Field arrows
###
inc: (event, args)-> @_inc event.currentTarget, yes
dec: (event, args)-> @_inc event.currentTarget, no
_inc: (btn, isInc)->
	if (cntrl= btn.closest '.f-cntrl') and ((input= cntrl.querySelector 'input.active-input') or (input= cntrl.querySelector 'input'))
		# Step
		step= +input.step
		step=1 if isNaN(step) or step<=0
		# min & max
		min= if input.hasAttribute('min') then +input.min else -Infinity
		max= if input.hasAttribute('max') then +input.max else Infinity
		hasLoop= input.hasAttribute 'd-loop'
		# Calc
		value= parseFloat(input.value)
		value= 0 if isNaN value
		if isInc
			value+= step
			if value>max
				value= if hasLoop then min else max
		else
			value-= step
			if value<min
				value= if hasLoop then max else min 
		# descimal
		value= value.toFixed d if input.hasAttribute('d-decimals') and (d= +input.getAttribute 'd-decimals') and Number.isSafeInteger(d) and d>0
		input.value= value
		input.focus()
	return