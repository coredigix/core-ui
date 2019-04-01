
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
	###*
	 * Validate form before submit
	 * @example
	 * v-submit	: Validate form and submit
	 * v-submit="cb": Validate form and then call cb (will prevent submit, cb must call submit to do it)
	###
	.watchSync 'form[v-submit]',
		submit: (event)->
			try
				# prevent submit
				event.preventDefault()
				# validate form
				$f= $ this
				fails= no
				# simple validations
				for attr in ['v-trim', 'v-regex', 'v-type']
					for inp in $f.find "[#{attr}]"
						fails= yes if vOperations[attr](inp) is no
				# cb validations
				jobs= []
				for inp in $f.find '[v-cb]'
					jobs.push vOperations['v-cb'] inp
				if jobs.length
					jobs= await Promise.all jobs
					fails = fails or jobs.some (resp)-> resp is false
				# check if failed
				if fails
					$f.find('.has-error input').addClass 'has-error-anim'
						.animationOnce ->
							@removeClass 'has-error-anim'
						.first()
						.focus()
						.select()
				else
					console.log '---- no fail'
					# check for cb
					cb= @getAttribute 'v-submit'
					if cb=V_CUSTOM_CB[cb]
						cb.call this, event
					else
						# submit form
						@submit()
			catch err
				Core.fatalError 'v-submit', err
			return
			