###*
 * Init DOM elements when loading html
###
_init: [] # Store init functions
###*
 * Push init function
###
init: (parentElement)->
	if typeof parentElement is 'function'
		@_init.push parentElement
	else
		parentElement?= document
		for cb in @_init
			cb parentElement
		# Init components
		for $component in parentElement.querySelectorAll '.component-init'
			try
				$component.classList.remove 'component-init'
				throw 'Missing attribute d-component' unless componentName= $component.getAttribute 'd-component'
				throw "Unknown component: #{componentName}" unless component= COMPONENTS_MAP[componentName]
				component.getInstance $component
			catch err
				Core.fatalError 'Init component', err 
	this # chain

