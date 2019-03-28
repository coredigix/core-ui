###*
 * <%= PKG.name %> <%= PKG.version %>
###
do ->
	'use strict'
	# check body loaded
	unless document.body
		throw new Error "Please add this library in the bottom of your HTML file"
	# utils
	_defineProperty= Object.defineProperty
	_defineProperties= Object.defineProperties
	_create= Object.create
	# general used vars
	$body = $ document.body
	# core
	Core= _create null,
		# logger
		debug: value: console.log.bind console
		info: value: console.info.bind console
		warn: value: console.warn.bind console
		error: value: console.error.bind console
		fatalError: value: console.error.bind console

	#=include _classess.coffee
	#=include _router.coffee
	
	### REACTOR ###
	do ->
		#=include reactor/_index.coffee
	
	# interface
	_defineProperties Core,
		Router: value: new Router()

	#interface
	window.Core= Core
	return