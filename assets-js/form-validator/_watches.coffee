
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