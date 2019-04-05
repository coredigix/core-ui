###*
 * Alerts
 * @return {Promise}
###


_alertMsg= (modal)->
	(msg, options)->
		if typeof options is 'string'
			options=
				msg: msg,
				type: options
		else if typeof options is 'object' and options
			options.msg= msg
		else
			options= msg: msg
		# button content
		options.ok ?= i18n.ok
		options.cancel ?= i18n.cancel
		# create message
		msg= Components._ modal, options
		msg= msg.children[0]
		document.body.append msg
		# listen to click on ok
		result= await new Promise (res, rej)->
			$ '[d-action="ok"]', msg
				.click -> res true
			$ '[d-action="cancel"]', msg
				.click -> res false
			return
		# remove modal
		$(msg).remove()
		return result

_defineProperties Core,
	###*
	 * alert
	 * @param  {String} msg     - message to alert
	 * @param  {String} options.type - info, warn, danger, success
	 * @param  {String} options.button - button label
	###
	alert: value: _alertMsg 'alert'
	# confirms
	confirm: value: _alertMsg 'confirm'
		