###*
 * DOM utilities
###
$body = $ document.body
Core.F_FILES_LIST= F_FILES_LIST= Symbol 'selected files'


_defineProperties Core,
	###*
	 * get Page Base URL
	###
	baseURL:
		configurable: true
		get: ->
			b= document.getElementsByTagName 'base'
			b= b[0]?.href or document.location.href
			_defineProperty this, 'baseURL', value: b
			return b


	###*
	 * Do element is parent of
	###
	isParentOf: value: (parent, child)->
		return true if parent is document
		while child
			return true if child is parent
			child= child.parentNode
		return false
