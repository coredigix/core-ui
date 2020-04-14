###*
 * Highlight syntax
###
syntax: do->
	# Highlight syntax
	#TODO
	_highlight= (code, language)->
		# TODO
		code= code.replace(/</g, '&lt;').replace(/>/g, '&gt;')
		code
	# Interface
	return (code, language)->
		# highlight
		code= _highlight code, language or 'generic'
		# split into lines
		ol= document.createElement 'ol'
		ol.innerHTML= "<li>#{code.split(/\n/g).join '</li><li>'}</li>"
		return ol

	