###*
 * <%= PKG.name %> <%= PKG.version %>
###
do ->
	'use strict'
	MOBILE_WIDTH= 600 # mobile size
	# check body loaded
	unless document.body
		throw new Error "Please add this library in the bottom of your HTML file"
	unless $?
		throw new Error "jQuery is required."
	# utils
	_defineProperty= Object.defineProperty
	_defineProperties= Object.defineProperties
	_create= Object.create
	_assign= Object.assign
	# general used vars
	$body = $ document.body
	F_FILES_LIST= Symbol 'selected files'
	# core
	Core= _create null,
		# logger
		debug: value: console.log.bind console
		info: value: console.info.bind console
		warn: value: console.warn.bind console
		error: value: console.error.bind console
		fatalError: value: console.error.bind console

	#=include _utils.coffee
	#=include _alerts.coffee
	#=include _classess.coffee
	#=include _router.coffee
	#=include jquery-plugins/_main.coffee
	
	### REACTOR ###
	do ->
		#=include reactor/_index.coffee
		return
	# main core reactor
	CORE_REACTOR= new Reactor()

	### AJAX ###
	do ->
		#=include ajax/_main.coffee
		return
	### FORM VALIDATOR ###
	do ->
		#=include form-validator/_main.coffee
		return
	### CLICK actions ###
	do ->
		#=include actions/_main.coffee
		return
	
	# interface
	_defineProperties Core,
		Router: value: new Router()

	#interface
	window.Core= Core
	return