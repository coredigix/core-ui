###*
 * Alerts
 * @return {Promise}
###


_alertMsg= (type)->
	(msg)->
		#TODO
		alert msg
		return
_defineProperties Core,
	# alerts
	alert: value: _alertMsg 'danger'
	alertOk: value: _alertMsg 'success'
	alertInfo: value: _alertMsg 'info'
	alertWarn: value: _alertMsg 'warn'

	# confirms
	confirm: value: (msg)->
		confirm msg