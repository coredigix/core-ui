###*
 * Component basic class
###
class Component extends EventEmitter
	constructor: (htmlElement)->
		htmlElement[COMPONENT_SYMB]= this
		@element= htmlElement
		@factory= @constructor.factory
		# Flags
		@$progress= null # Tmp progress bar
		@htmlRender= null # Function that will do html render
		@_properties= null # Properties
		return

	###*
	 * Get element attributes
	###
	getAttributes: ->
		attrs= {}
		element= @element
		for k in element.getAttributeNames()
			k2= if k.startsWith('d-') then k.slice 2 else k
			attrs[k2]= element.getAttribute k
		return attrs

	###*
	 * Render HTML
	###
	render: (attrs)->
		newElement= _toHTMLElement @htmlRender attrs # this is faster than using "Core.html._" method
		# Remplace previous element
		element= @element
		@element= newElement
		newElement[COMPONENT_SYMB]= this
		if parent= element.parentNode
			parent.insertBefore newElement, element
			parent.removeChild element
		this # chain

	###* Events ###
	#=include component-prototype/_*.coffee