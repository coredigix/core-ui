
###*
 * Progress (from 0-100 )
###
progress: (loaded, total)->
	$progress= @$progress or @$element.find('.progress:first')
	$progressTrack= $progress.find '.track:first'
	if total is Infinity
		$progress.addClass 'loading'
	else
		$progress.removeClass 'loading'
		$progressTrack.css 'width', "#{loaded*100/total}%"
	return
###*
 * Do Error animation on a form element
###
doErrorAnimation: (element)->
	$(element).closest('.f-cntrl')
		.addClass 'has-error-anim'
		.animationOnce ->
			@removeClass 'has-error-anim'
		.first()
		.focus()
		.select()
	return


###*
 * Execute validation on input when blur
###
_triggerBlurValidation: (element)->
	console.log 'trigger blur>', element
	element[INPUT_VALIDATED]= no
	$fcntrl= $(element).closest('.f-cntrl').addClass 'loading'
	state= false
	try
		actions= @type._blurActions
		value= element.value
		# Check it's a valid html element
		if attributes= element.getAttributeNames?()
			for attrName in attributes
				if fx= actions[attrName]
					value= await fx.call element, value, element.getAttribute(attrName), this
			element.value= value # replace value
			# Has success
			$fcntrl.addClass 'has-done'
			element[INPUT_VALIDATED]= yes
			state= yes
	catch err
		$fcntrl.addClass if err is 'warn' then 'has-warn' else 'has-error'
		@type.emit 'error', err unless err in [false, 'warn']
	finally
		$fcntrl.removeClass 'loading'
		# trigger validation state
		@type.emit 'validate',
			component:	this
			element:	element
			status:		state
	return state

###*
 * Submit
###
_triggerSubmitValidation: (event)->
	form= event.target
	$form= $(form).removeClass('form-has-error').addClass('loading')
	try
		# Prevent sending
		event.preventDefault()
		# Validate form
		jobs= []
		formElements= form.elements
		for element in formElements
			state= element[INPUT_VALIDATED]
			if state?
				jobs.push state
			else
				jobs.push @_triggerBlurValidation element
		jobs= await Promise.all jobs
		for v,i in jobs
			if v is no
				# do animation
				@doErrorAnimation formElements[i]
				throw no
		# Callbacks before submit on elements
		for element in formElements
			if attr= element.getAttribute 'v-submit'
				parts= attr.trim().split /\s+/
				cbName= parts[0].toLowerCase()
				cb= @type._vSubmit[cbName]
				throw new Error "Unknown submit callback: #{cbName}" unless cb
				await cb.call element, event, parts, this
		# Check for cb
		if attr= form.getAttribute 'v-submit'
			parts= attr.trim().split /\s+/
			cbName= parts[0].toLowerCase()
			cb= @type._vSubmit[cbName]
			throw new Error "Unknown submit callback: #{cbName}" unless cb
			await cb.call form, event, parts, this
		else
			form.submit()
	catch err
		unless (err is no) or (err?.aborted) # err.aborted => ajax
			$form.addClass 'form-has-error'
			@type.emit 'error', err
	finally
		$form.removeClass 'loading'
	return
