###*
 * Event wrapper
###
EventWrapper:		EventWrapper
ROOT_COMPONENT:		ROOT_COMPONENT
$ROOT_COMPONENT:	$ROOT_COMPONENT
F_FILES_LIST:		F_FILES_LIST

###*
 * Components
###
_components: {}
component: (componentName)->
	throw new Error 'Illegal arguments' unless arguments.length is 1 and typeof componentName is 'string'
	componentName= componentName.toLowerCase()
	unless component= @_components[componentName]
		component= @_components[componentName]= new ComponentFactory()
	return component

###*
 * ROUTE COMPONENT METHODS
###
watch:		ROOT_COMPONENT.watch.bind ROOT_COMPONENT
watchSync:	ROOT_COMPONENT.watchSync.bind ROOT_COMPONENT

addAction:		ROOT_COMPONENT.addAction.bind ROOT_COMPONENT
addActionSync:	ROOT_COMPONENT.addActionSync.bind ROOT_COMPONENT

define:			ROOT_COMPONENT.define.bind ROOT_COMPONENT
defineEvent:	ROOT_COMPONENT.defineEvent.bind ROOT_COMPONENT

vCb:			ROOT_COMPONENT.vCb.bind ROOT_COMPONENT
vSubmit:		ROOT_COMPONENT.vSubmit.bind ROOT_COMPONENT
vAdd:			ROOT_COMPONENT.vAdd.bind ROOT_COMPONENT
vType:			ROOT_COMPONENT.vType.bind ROOT_COMPONENT