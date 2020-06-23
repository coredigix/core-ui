###*
 * Component basic class
 * Expected methods to be defined by the user:
 * 		htmlRender: Render the HTML
###
class Component extends EventEmitter
	###*
	 * Private attributes
	 * <!>	When added private attribute, do not forget to add
	 * 		it to subclasses in _interface.coffee:component
	###
	_watch			: {}
	_watchSync		: {}

	_linkEvents		: {}
	_customEvents	: {}

	_vAttrs: # Validation attributes
		#=include form-validation/_attributes.coffee
	###* Constructor ###
	constructor: (htmlElement)->
		super()
		# Core
		@element= null
		@htmlRender= null # The fx that will render the component
		# Flags
		@$progress= null # Tmp progress bar
		@_properties= null # Private properties
		@_enabled= yes # If the component is Enabled
		# Index this component
		@setElement htmlElement if htmlElement
		return
	###* Init element ###
	setElement: (newElement)->
		previousElement= @element
		if newElement isnt previousElement
			@element= newElement
			newElement[COMPONENT_SYMB]= this
			unless newElement is document
				newElement.classList.add 'coreComponent'
				if previousElement and (parent= previousElement.parentNode)
					parent.insertBefore newElement, previousElement
					parent.removeChild previousElement
		this # chain
	###* Get element attributes ###
	getAttributes: ->
		attrs= {}
		element= @element
		for k in element.getAttributeNames()
			k2= if k.startsWith('d-') then k.slice 2 else k
			attrs[k2]= element.getAttribute k
		return attrs

	###* Render HTML ###
	render: ->
		throw new Error "Render function missing" unless typeof @htmlRender is 'function'
		newElement= _toHTMLElement @htmlRender @_properties # this is faster than using "Core.html._" method
		@setElement newElement
		this # chain

	###* Create instance of HTML element ###
	@getInstance: (element)->
		unless component= element[COMPONENT_SYMB]
			component= new this(element)
		return component

	###* Event when window resized ###
	onWindowResize: (event)->
	onWindowBlur: (event)->

	#=include static/_*.coffee
	#=include prototype/_*.coffee
	#=include custom-events/_listeners.coffee
	#=include form-validation/_methods-*.coffee
	#=include basic-actions/_*.coffee
	

# Map this component
COMPONENTS_MAP['component']= Component
COMPONENTS_MAP_CHILDS.set Component, [Component]

#=include custom-events/_link-events.coffee
#=include form-validation/_native.coffee

###*
 * ROOT COMPONENT
###
ROOT_COMPONENT= new Component document