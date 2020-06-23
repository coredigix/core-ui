###*
 * Auto-complete field
 * Create new autocomplete controller
 * @param {String} name - autocomplete controller name
 * @param {Function} options.getData(element) - Function that will load the data, it must return a promise with "abort" function
 * @param {Function} options.render(data,element, ) - function that will render received data
 * @param {Function} options.onSelect.call(element, option) - function will be called when an option is selected
###
autocomplete: (name, options)->
	try
		# Checks
		throw "Illegal arguments" unless arguments.length is 1 and typeof name is 'string' and typeof options is 'object' and options
		throw 'options.getData expected function' unless typeof options.getData is 'function'
		throw 'options.render expected function' unless typeof options.render is 'function'
		throw 'options.onSelect expected function' unless typeof options.onSelect is 'function'
		throw "#{name} already defined" if @_autocomplete.hasOwnProperty name
		# add
		@_acMethods[name]=
			getData:	options.getData
			render:		options.render
			onSelect:	options.onSelect
	catch err
		err= new Error "autocomplete>> #{err}" if typeof err is 'string'
		throw err
	this # chain
