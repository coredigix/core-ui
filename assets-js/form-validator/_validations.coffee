Core.EMAIL_REGEX= regexEmail= /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
regexTel= /^0\d+$/

validateCb=
	empty: (data)->
		dt= data.trim()
		throw 0 if dt
		throw 1
	email: (data)->
		dt= data.trim()
		throw 0 unless regexEmail.test dt
		return dt
	tel: (data)->
		data= data.replace /[\s-]/g, ''
		throw 0 unless regexTel.test data
		data
	password: (data)->
		throw 0 unless 6 <= data.length <= 100
		data
	number: (data)->
		throw 0 if data is ''
		data= +data
		throw 0 if isNaN data
		data
	'>0': (data)-> # strict positive number
		data= +data
		throw 0 if (isNaN data) or data <= 0
		data
	price: (data)-> # monai
		data= +data
		throw 0 if (isNaN data) or data <= 0
		data.toFixed 2


vOperations=
	### trim ###
	'v-trim': (input)->
		input.value= input.value.trim()
		return
	### type ###
	'v-type': (input)->
		isOk= no
		for tp in input.getAttribute('v-type').toLowerCase().split(',')
			k= validateCb[tp]
			if k
				try
					input.value= k input.value
					isOk= yes
					break
				catch err
					if err is 1
						isOk= null
						break
					else unless err is 0
						Core.error 'v-type', err
			else
				Core.warn 'v-type', "Unknown type #{k}"
		# toggle class
		$inp= $(input).closest '.f-cntrl'
		if isOk is null
			$inp.removeClass 'has-error has-done'
		else
			$inp.toggleClass 'has-error', not isOk
				.toggleClass 'has-done', isOk
		return isOk
	### regex ###
	'v-regex': (input)->
		rex= new RegExp input.getAttribute 'v-regex'
		isOk= rex.test input.value
		# toggle class
		$(input).closest '.f-cntrl'
			.toggleClass 'has-error', not isOk
			.toggleClass 'has-done', isOk
		return isOk
	### Custom cb ###
	'v-cb': (input)->
		$inp= $(input).closest('.f-cntrl').addClass 'loading no-events'
		try
			cb= V_CUSTOM_CB[input.getAttribute 'v-cb']
			throw "Unknown cb: #{input.getAttribute 'v-cb'}" unless cb
			isOk= await cb.call input, input
		catch err
			if err is 1 # no value
				isOk= null
			else
				Core.fatalError 'v-cb', err
				isOk= no
		# state
		$inp.removeClass 'loading no-events has-error has-done has-warn'
		switch isOk
			when true
				$inp.addClass 'has-done'
			when false, 'error'
				$inp.addClass 'has-error'
			when 'warn'
				$inp.addClass 'has-warn'
		return isOk
