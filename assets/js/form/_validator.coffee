###*
 * Form validator
###
# FORMAT CONTROLE
_formElementValidator= (element, event)->
	try
		resp= true
		$fcntrl= $(element).closest('.f-cntrl')
		# TRIM ---
		originalValue= value= element.value
		if element.hasAttribute 'v-trim'
			value= value.trim()
		# REGEX ---
		if attr= element.getAttribute 'v-regex'
			attr= new RegExp attr
			throw false unless attr.test value
		# MIN ---
		if attr= element.getAttribute 'v-min'
			if element.type is 'file'
				files= element[F_FILES_LIST] or element.files
				cnt= files?.length
				throw false if cnt < +attr
			else
				value= +value
				throw false if isNaN(value) or value < +attr
		# MAX ---
		if attr= element.getAttribute 'v-max'
			if element.type is 'file'
				files= element[F_FILES_LIST] or element.files
				cnt= files?.length
				throw false if cnt > +attr
			else
				value= +value
				throw false if isNaN(value) or value > +attr
		# max-size
		if attr= element.getAttribute 'v-max-bytes'
			if (element.type is 'file') and (files= element[F_FILES_LIST] or element.files)
				total= 0
				for f in files
					total+= f.size
				throw false if total > +attr
		# min-size
		if attr= element.getAttribute 'v-min-bytes'
			if (element.type is 'file') and (files= element[F_FILES_LIST] or element.files)
				total= 0
				for f in files
					total+= f.size
				throw false if total < +attr
		# TYPE ---
		if attr= element.getAttribute 'v-type'
			for tp in attr.toLowerCase().split(',')
				op= TYPE_OPERATIONS[tp.trim()]
				throw new Error "Unknown type: #{tp}" unless op
				resp= await op.call element, value, event
				value= resp.value if resp?.hasOwnProperty 'value'
				# stop if one predicat returns true
				unless resp is false or resp.error or resp.warn
					resp= true
					break
			throw resp unless resp is true
		# FIXED
		if attr= element.getAttribute 'v-fixed'
			attr= +attr
			value= +value
			throw false if isNaN(value) or isNaN(attr)
			value= value.toFixed attr
		# CHECKED
		if element.hasAttribute 'v-checked'
			throw false unless element.checked
		# v-cb ---
		if attr= element.getAttribute 'v-cb'
			op= V_CUSTOM_CB[attr]
			throw "Unknown v-cb: #{attr}" unless op
			# add loading
			$fcntrl.addClass 'loading'
			resp= await op.call element, value, event
			throw resp if resp is false or resp.error or resp.warn
			value= resp.value if resp.hasOwnProperty 'value'
		# Save ---
		if value isnt originalValue
			element.value= value
		# has success
		if value
			$fcntrl.addClass 'has-done'
		if typeof resp.done is 'string'
			$fcntrl.find('.when-done').html resp.done
		return true
	catch err
		$fcntrl.removeClass 'loading'
		if err is false
			$fcntrl.addClass 'has-error'
		else if err?
			if err.error
				$fcntrl.addClass 'has-error'
				if typeof err.error is 'string'
					$fcntrl.find('.when-error').html err.error
			else if err.warn
				$fcntrl.addClass 'has-warn'
				if typeof err.warn is 'string'
					$fcntrl.find('.when-warn').html err.warn
			else
				Core.fatalError 'form-validator', err
		else
			Core.fatalError 'form-validator', 'Uncaught error'
		return false

_privateWatcher.watch 'input, textarea', 'focus', (event)->
	$(this).closest('.f-cntrl').removeClass 'has-error has-done has-warn'
	return
_privateWatcher.watch 'input, textarea', 'blur', (event)->
	_formElementValidator this, event
	return

###*
 * Custom callbacks
###
_defineProperties Core,
	vCb: value: (name, cb)->
		# checks
		throw new Error "Expected 2 arguments" unless arguments.length is 2
		throw new Error "Expected cb name" unless typeof name is 'string'
		throw new Error "Expected cb as function" unless typeof cb is 'function'
		throw new Error "vCb already set: #{name}" if  V_CUSTOM_CB[name]
		# add
		V_CUSTOM_CB[name]= cb
		this # chain
	vSubmit: value: (name, cb)->
		# checks
		throw new Error "Expected 2 arguments" unless arguments.length is 2
		throw new Error "Expected cb name" unless typeof name is 'string'
		throw new Error "Expected cb as function" unless typeof cb is 'function'
		throw new Error "vSubmit already set: #{name}" if  V_SUBMIT_CB[name]
		# add
		V_SUBMIT_CB[name]= cb
		this # chain
