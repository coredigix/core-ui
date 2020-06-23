###* Hover ###
hover: do ->
	hoverFlag= Symbol 'hover'
	return (event, args)->
		currentTarget= event.currentTarget
		unless currentTarget[hoverFlag]
			# set flag to flase when quiting the element
			currentTarget[hoverFlag]= yes
			outListener= (evnt)->
				unless _isParentOf currentTarget, evnt.target
					currentTarget[hoverFlag]= no
					window.removeEventListener 'mouseover', outListener, {capture: true, passive: true}
				return
			window.addEventListener 'mouseover', outListener, {capture: true, passive: true}
			# Execute handler
			args= args.slice 1
			handlerName= args[0].toLowerCase()
			@[handlerName] (new EventWrapper 'hover', event, currentTarget, currentTarget, event.isSync), args
		return

###* Hout ###
hout: do ->
	houtFlag= Symbol 'hout'
	return (event, args)->
		currentTarget= event.currentTarget
		unless currentTarget[houtFlag] # if not already entred
			currentTarget[houtFlag]= true
			outListener= (evnt)=>
				unless _isParentOf currentTarget, evnt.target
					currentTarget[houtFlag]= no
					window.removeEventListener 'mouseover', outListener, {capture: true, passive: true}
					args= args.slice 1
					handlerName= args[0].toLowerCase()
					@[handlerName] (new EventWrapper 'hout', evnt, currentTarget, currentTarget, no), args
				return
			window.addEventListener 'mouseover', outListener, {capture: true, passive: true}
		return
