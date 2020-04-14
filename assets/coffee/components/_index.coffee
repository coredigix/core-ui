###*
 * Components
###

#=include _const.coffee
#=include _utils.coffee
#=include _enable-native-event.coffee
#=include _event-wrapper.coffee
#=include _main.coffee

###*
 * Execute form validation native listeners
###
do ->
	#=include form-validators/_native-listeners.coffee
	return

###*
 * Custom events
###
do ->
	#=include custom-events/_*.coffee
	return