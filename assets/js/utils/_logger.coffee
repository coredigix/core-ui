###*
 * Logger
###
_defineProperties Core,
	# logger
	debug: value: console.log.bind console
	info: value: console.info.bind console
	warn: value: console.warn.bind console
	error: value: console.error.bind console
	fatalError: value: console.error.bind console