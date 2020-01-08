###*
 * FORM RESET
###
_privateWatcher.watch 'form', 'reset', (event)->
	# remove state classes
	$('has-error has-done has-warn', this).removeClass 'has-error has-done has-warn'
	# empty file upload queue
	for inp in @querySelectorAll 'input[type="file"]'
		if queue= inp[F_FILES_LIST]
			queue.splice 0
	$('.files-preview', this).empty()
	# ends
	return


###*
 * FORM SUBMIT
###
_formSubmitCaller= (event)->
	try
		# prevent submit
		event= event.originalEvent if event.originalEvent
		event?.preventDefault()
		$(this).addClass 'loading'
		# validate form
		jobs= []
		for element in @elements
			jobs.push _formElementValidator element
		jobs= await Promise.all jobs
		throw false if jobs.some (vl)-> vl is false
		# call before submit events
		for element in @elements
			if attr= element.getAttribute 'v-submit'
				attr= attr.split /\s+/
				m= attr.shift()
				cb= V_SUBMIT_CB[m]
				throw new Error "Unknown submit cb: #{m}" unless cb
				await cb.apply element, attr
		# check for cb
		if attr= @getAttribute 'v-submit'
			cb= V_SUBMIT_CB[attr]
			throw new Error "Unknown submit cb: #{attr}" unless cb
			await cb.call this, event
		else
			@submit()
	catch err
		if err is false
			$(this).find('.has-error .f-input, .has-warn .f-input').addClass 'has-error-anim'
				.animationOnce ->
					@removeClass 'has-error-anim'
				.first()
				.focus()
				.select()
		else unless err
			Core.error 'submit', 'Unknown error'
		else if err.aborted
			# Ajax aborted
			Core.debug 'submit', 'Ajax aborted'
		else if err.error
			# Ajax error
			#TODO
		else
			Core.error 'submit', err
	finally
		$(this).removeClass 'loading'
	return
	
_privateWatcher.watchSync 'form[v-submit]', 'submit', _formSubmitCaller

# submit buttons
Core.addAction 'click', 'submit', (event)->
	if f= @closest 'form'
		if f.hasAttribute 'v-submit'
			_formSubmitCaller.call f
		else
			f.submit()
	return
	