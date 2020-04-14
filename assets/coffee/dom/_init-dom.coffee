###*
 * Init DOM elements when loading html
###
_init: [] # Store init functions
###*
 * Push init function
###
addInit: (cb)-> @_init.push cb
init: (parentElement)->
	parentElement?= document
	for cb in @_init
		cb parentElement
	this # chain

