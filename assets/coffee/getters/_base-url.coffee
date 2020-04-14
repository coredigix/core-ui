###*
 * Get document base URL
###
_defineProperty Core, 'baseURL', configurable: yes, get: ->
	b= document.getElementsByTagName 'base'
	href= (b= b[0]) and b.href or document.location.href
	_defineProperty this, 'baseURL', value: href
	return href
