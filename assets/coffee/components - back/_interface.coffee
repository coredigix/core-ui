###*
 * Event wrapper
###
EventWrapper:		EventWrapper
ROOT_COMPONENT:		ROOT_COMPONENT
$ROOT_COMPONENT:	$ROOT_COMPONENT
F_FILES_LIST:		F_FILES_LIST

###*
 * Components
 * @param {String} componentName - name of the component
 * @param {Function} initFx - function($component){} init the component if required
###
component: (componentName, initFx)->
	throw new Error 'Illegal arguments' unless arguments.length in [1,2] and typeof componentName is 'string'
	throw new Error 'Illegal initiator' if initFx and not (typeof initFx is 'function')
	componentName= componentName.toLowerCase()
	unless component= COMPONENTS_MAP[componentName]
		component= COMPONENTS_MAP[componentName]= new ComponentFactory(initFx)
	return component

###*
 * ROUTE COMPONENT METHODS
###
watch:		ROOT_COMPONENT.watch.bind ROOT_COMPONENT
watchSync:	ROOT_COMPONENT.watchSync.bind ROOT_COMPONENT

addAction:		ROOT_COMPONENT.addAction.bind ROOT_COMPONENT
addActionSync:	ROOT_COMPONENT.addActionSync.bind ROOT_COMPONENT

defineEvent:	ROOT_COMPONENT.defineEvent.bind ROOT_COMPONENT

vCb:			ROOT_COMPONENT.vCb.bind ROOT_COMPONENT
vSubmit:		ROOT_COMPONENT.vSubmit.bind ROOT_COMPONENT
vAdd:			ROOT_COMPONENT.vAdd.bind ROOT_COMPONENT
vType:			ROOT_COMPONENT.vType.bind ROOT_COMPONENT