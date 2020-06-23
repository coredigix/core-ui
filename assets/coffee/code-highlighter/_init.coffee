###*
 * Add to init function
###
Core.init (parent)->
	renderSyntax= Core.syntax
	for element in parent.querySelectorAll 'pre.code'
		try
			ol= renderSyntax element.innerText, element.getAttribute('d-language')
			olCl= ol.classList
			olCl.add.apply olCl, element.className.split /\s+/
			parent= element.parentNode
			parent.insertBefore ol, element
			parent.removeChild element
		catch err
			ROOT_COMPONENT.emit 'error', err
	return