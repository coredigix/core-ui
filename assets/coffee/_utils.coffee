###*
 * OBJECT
###
_create=					Object.create
_assign=					Object.assign
_keys=						Object.keys
_defineProperty=			Object.defineProperty
_defineProperties=			Object.defineProperties
_getOwnPropertyDescriptor=	Object.getOwnPropertyDescriptor
_getOwnPropertyDescriptors=	Object.getOwnPropertyDescriptors

# Array
_isArray= Array.isArray
_isStrArray= (arr)->
	return false unless _isArray arr
	for el in arr
		return false unless typeof el is 'string'
	return true

# Parse HTML and returns element
_toHTMLElementDiv= document.createElement 'div'
_toHTMLElement= (html)->
	# create element
	_toHTMLElementDiv.innerHTML= html
	element= _toHTMLElementDiv.firstElementChild
	# Empty div
	while el= _toHTMLElementDiv.firstChild
		_toHTMLElementDiv.removeChild el
	# return
	return element

# ESCAPE HTML
escapeHTML_txtNode= document.createTextNode('')
escapeHTML_txtParent= document.createElement('div')
escapeHTML_txtParent.appendChild escapeHTML_txtNode
escapeHTML= (str)->
	escapeHTML_txtNode.nodeValue= str
	return escapeHTML_txtParent.innerHTML


###*
 * Safe integer
###
# _safeInt= (expr, defaultValue)->
# 	expr= +expr
# 	return if Number.isSafeInteger expr then expr else defaultValue

_safeNumber= (value, defaultValue)->
	value= +value
	return if typeof value is 'number' and Number.isFinite(value) then value else defaultValue