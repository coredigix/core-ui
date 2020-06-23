###* Do Error animation on a form element ###
doErrorAnimation: (element)->
	$(element).closest('.f-cntrl')
		.addClass 'has-error-anim'
		.animationOnce ->
			@removeClass 'has-error-anim'
		.first()
		.focus()
		.select()
	return


###* Execute validation ###
_triggerBlur: (element)->
	# Check it's form element (not Anchor or other)
	if element.form?
		element[INPUT_VALIDATED]= no
		$fcntrl= $(element).closest('.f-cntrl').addClass 'loading'
		state= false
		try
			vAttributes= @_vAttrs
			value= element.value
			# Check it's a valid html element
			if attributes= element.getAttributeNames?()
				for attrName in attributes
					if handler= vAttributes[attrName]
						value= await handler.call this, value, element, element.getAttribute(attrName)
				if element.type isnt 'file'
					element.value= value # replace value
				# Has success
				$fcntrl.addClass 'has-done'
				element[INPUT_VALIDATED]= yes
				state= yes
		catch err
			if err is 'warn'
				$fcntrl.addClass 'has-warn'
			else
				$fcntrl.addClass 'has-error'
				@emit 'form-error', err unless err is false
		finally
			$fcntrl.removeClass 'loading'
			# trigger validation state
			@emit 'validate',
				element:	element
				status:		state
	return state

###* FORM RESET ###
_onFormReset: (event)->
	form= event.target
	# remove state classes
	$('has-error has-done has-warn', form).removeClass 'has-error has-done has-warn'
	# empty file upload queue
	for inp in @querySelectorAll 'input[type="file"]'
		if queue= inp[F_FILES_LIST]
			queue.length= 0
	$('.files-preview', form).empty()
	# Emit this event
	@emit 'form-reset', event
	return

###* Form submit ###
_onSubmit: (event)->
	form= event.target
	$form= $(form).removeClass('form-has-error').addClass('loading')
	try
		# Prevent sending
		event.preventDefault()
		# Validate form
		jobs= []
		formElements= form.elements
		for element in formElements
			if (state= element[INPUT_VALIDATED])?
				jobs.push state
			else unless element.disabled
				jobs.push @_triggerBlur element
		jobs= await Promise.all jobs
		for v,i in jobs
			if v is no
				# do animation
				@doErrorAnimation formElements[i]
				throw no
		# Callbacks before submit on elements
		for element in formElements
			if attr= element.getAttribute 'v-submit'
				console.log 'submit: ', attr
				parts= attr.trim().split /\s+/
				cbName= parts[0]
				throw new Error "Unknown method for submit: #{cbName}" unless typeof @[cbName] is 'function'
				await @[cbName] element, parts
		# Check for cb
		if attr= form.getAttribute 'v-submit'
			parts= attr.trim().split /\s+/
			cbName= parts[0]
			throw new Error "Unknown method for submit: #{cbName}" unless typeof @[cbName] is 'function'
			await @[cbName] event, parts
		else
			form.submit()
	catch err
		unless (err is no) or (err?.aborted) # err.aborted => ajax
			$form.addClass 'form-has-error'
			@emit 'form-error', err
	finally
		$form.removeClass 'loading'
	return



