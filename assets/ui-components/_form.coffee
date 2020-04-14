###*
 * Predefined actions
###
ROOT_COMPONENT
# SUBMIT
.addAction 'click', 'submit', (event)->
	if form= @closest 'form'
		if form.hasAttribute 'v-submit'
			_closestComponent(form)._triggerSubmitValidation event
		else
			form.submit()
	return
