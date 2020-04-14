#=include _utils.coffee
#=include _const.coffee
#=include events/_index.coffee
#=include components/_index.coffee
#=include ajax/_index.coffee
#=include jquery/_index.coffee
#=include router/_index.coffee

# core
Core=
	#=include miscellaneous/_*.coffee
	#=include ajax/_interface.coffee
	#=include dom/_*.coffee
	#=include components/_interface.coffee
	#=include router/_interface.coffee
	#=include code-highlighter/_interface.coffee

#=include getters/_*.coffee
#=include code-highlighter/_init.coffee

# Init DOM
$ Core.init.bind Core, document