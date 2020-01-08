###*
 * FORM
###
F_FILES_LIST= Symbol 'file list'
V_CUSTOM_CB= _create null # store custom callbacks
V_SUBMIT_CB= _create null # store custom callbacks

_defineProperties Core,
	F_FILES_LIST: value: F_FILES_LIST

#=include _validation-types.coffee
#=include _validator.coffee
#=include _form.coffee
#=include _upload.coffee
#=include _submit-default.coffee