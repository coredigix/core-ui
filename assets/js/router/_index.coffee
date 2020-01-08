###*
 * Router
###
#=include _tree.coffee
#=include _router.coffee

# Default goto
Core.goto= (url)->
	document.location= url
	return