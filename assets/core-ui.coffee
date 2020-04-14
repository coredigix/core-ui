###*
 * Core UI framework
###
do ->
	'use strict'
	MOBILE_WIDTH= 600 # mobile size
	# check body loaded
	# unless document.body
	# 	throw new Error "Please add this library in the bottom of your HTML file"
	unless jQuery?
		throw new Error "jQuery is required."
	$= jQuery
	#=include coffee/_index.coffee
	
	# UI-COMPONENTS
	do ->
		#=include ui-components/_*.coffee
		return
	
	#interface
	window.Core= Core
	return