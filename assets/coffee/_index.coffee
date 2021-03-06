#=include _utils.coffee
#=include _const.coffee
#=include events/_index.coffee
#=include components/_index.coffee
#=include ajax/_index.coffee
#=include jquery/_index.coffee
#=include miscellaneous-head/_*.coffee

# core
Core=
	version: '<%-version %>'
	html: null # Store HTML components
	#=include miscellaneous/_*.coffee
	#=include ajax/_interface.coffee
	#=include dom/_*.coffee
	#=include components/_interface.coffee
	#=include router/_interface.coffee
	#=include code-highlighter/_interface.coffee

#=include getters/_*.coffee
#=include code-highlighter/_init.coffee
#=include miscellaeous-body/_*.coffee

# Init DOM
$ Core.init.bind Core, document