###*
 * <%= PKG.name %> <%= PKG.version %>
###
do ->
	'use strict'
	# check body loaded
	unless document.body
		throw new Error "Please add this library in the bottom of your HTML file"
	# general used vars
	$body = $ document.body

	#=include _classess.coffee