
### listeners ###
CORE_REACTOR
	### trim ###
	.watch 'input[v-trim]',
		blur: (event)->
			vOperations['v-trim'] this
			return
	###*
	 * Input data type
	 * @example
	 * email, tel, number, 
	###
	.watch 'input[v-type], textarea[v-type]',
		blur: ->
			vOperations['v-type'] this
			return
	.watch 'input[v-regex], textarea[v-regex]',
		blur: ->
			vOperations['v-regex'] this
			return
	.watch 'input[v-cb], textarea[v-cb]',
		blur: ->
			vOperations['v-cb'] this
			return
	.watch 'input[v-max], textarea[v-max]',
		blur: ->
			vOperations['v-max'] this
			return

	### Remove state classes when form reset ###
	.watch 'form',
		reset: ->
			# remove state classes
			$ '.has-done, .has-error, .has-warn, .has-info', this
				.removeClass 'has-done .has-error has-warn has-info'
			# empty file upload queue
			for inp in @querySelectorAll 'input[type="file"]'
				if queue= inp[F_FILES_LIST]
					queue.splice 0
			$('.files-preview', this).empty()
			# ends
			return
###*
 * Validate form before submit
 * @example
 * v-submit	: Validate form and submit
 * v-submit="cb": Validate form and then call cb (will prevent submit, cb must call submit to do it)
###
_formSubmitCaller= (event)->
	try
		# prevent submit
		event?.preventDefault()
		# validate form
		$f= $ this
		fails= no
		# simple validations
		for attr in ['v-trim', 'v-regex', 'v-type', 'v-max']
			for inp in $f.find "[#{attr}]"
				fails= yes if vOperations[attr](inp) is no
		throw 0 if fails
		# cb validations
		jobs= []
		for inp in $f.find '[v-cb]'
			jobs.push vOperations['v-cb'] inp
		if jobs.length
			jobs= await Promise.all jobs
			throw 0 if jobs.some (resp)-> resp isnt true
		
		# check for cb
		cb= @getAttribute 'v-submit'
		if cb=V_CUSTOM_CB[cb]
			cb.call this, event
		else
			# submit form
			$(this).addClass 'loading'
			@submit()
	catch err
		# fail
		if err is 0
			$f.find('.has-error .f-input, .has-error .dropdown-value,.has-warn .f-input').addClass 'has-error-anim'
				.animationOnce ->
					@removeClass 'has-error-anim'
				.first()
				.focus()
				.select()
		# other error
		else
			Core.fatalError 'v-submit', err
	return
CORE_REACTOR.watchSync 'form[v-submit]',
		submit: _formSubmitCaller
# submit buttons
Core.addAction 'click', 'submit', (event)->
	f= @closest 'form'
	if f.hasAttribute 'v-submit'
		_formSubmitCaller.call f
	else
		f.submit()
	return