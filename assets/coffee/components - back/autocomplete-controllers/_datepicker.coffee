###*
 * Date picker
###
datepicker:
	getData: (txt)-> txt
	render: (data, popup)->
		datePickerComponentFactory= COMPONENTS_MAP['date-picker']
		# Create date picker
		if datePicker= popup.$body.querySelector '[d-component="date-picker"]'
			datePicker= datePickerComponentFactory.getComponent datePicker
			datePicker.setValue data
			popup.open()
			return null
		else
			# Load attributes
			attrs= {}
			for key in @getAttributeNames()
				attrs[key]= @getAttribute(key) if key.startsWith('d-')
			attrs['d-value']= data
			# HTML element
			result= _toHTMLElement Core.html.datePickerPopup(attrs)
			datePickerComponentFactory.getComponent result.querySelector '[d-component="date-picker"]'
			return result
	onSelect: (option)->
		console.log '---- datepicker selected: ', option
		return