###*
 * Core UI framework
###
do ->
	'use strict'
	MOBILE_WIDTH= 600 # mobile size
	# check body loaded
	# unless document.body
	# 	throw new Error "Please add this library in the bottom of your HTML file"
	unless $?
		throw new Error "jQuery is required."
	
	# core
	Core= Object.create null
	# utils
	#=include utils/_index.coffee
	# general used vars
	
	# DOM
	#=include dom/_index.coffee

	### AJAX ###
	do ->
		#=include ajax/_main.coffee
		return

	### JQUERY ###
	do ->
		#=include jquery/_index.coffee
		return
	### Router ###
	do ->
		#=include router/_index.coffee
		return

	### EVENT WATCHER ###
	do ->
		#=include event/_index.coffee
		return

	###*
	 * Form
	###
	_privateWatcher= new Core.Watcher()	# create a private watcher to be used by the framework
	#=include form/_index.coffee

		
	#interface
	window.Core= Core
	return