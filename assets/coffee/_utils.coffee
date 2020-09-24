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
	return false for el in arr when typeof el isnt 'string'
	return true

# Parse HTML and returns element
_toHTMLElementDiv= document.createElement 'div'
_toHTMLElement= (html)->
	# create element
	_toHTMLElementDiv.innerHTML= html
	element= _toHTMLElementDiv.firstElementChild
	# Empty div
	_toHTMLElementDiv.removeChild el while el= _toHTMLElementDiv.lastChild
	# return
	return element
_toHTMLFragment= (html)->
	frag= document.createDocumentFragment()
	_toHTMLElementDiv.innerHTML= html
	frag.appendChild element while element= _toHTMLElementDiv.firstChild
	return frag

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
