###*
 * hover
###
# Core.addEvent 'hover', 'mouseover', 
_hoverGenerator= (listener)->
	hoverFlag= Symbol 'hover flag'
	(event)->
		unless @[hoverFlag] # if not already entred
			@[hoverFlag]= true
			listener.call this, event
			# set flag to flase when quiting the element
			outListener= (evnt)=>
				unless Core.isParentOf this, evnt.target
					@[hoverFlag]= false
					window.removeEventListener 'mouseover', outListener, {capture: true, passive: true}
				return
			window.addEventListener 'mouseover', outListener, {capture: true, passive: true}
		return


###*
 * hover
###
_houtGenerator= (listener, selector)->
	houtFlag= Symbol 'hover flag'
	->
		unless @[houtFlag] # if not already entred
			@[houtFlag]= true
			# set flag to flase when quiting the element
			outListener= (evnt)=>
				unless Core.isParentOf this, evnt.target
					@[houtFlag]= false
					window.removeEventListener 'mouseover', outListener, {capture: true, passive: true}
					listener.call this, new EventWrapper evnt, 'hout', selector, this
				return
			window.addEventListener 'mouseover', outListener, {capture: true, passive: true}
		return

ROOT_COMPONENT
.defineEvent 'hover', 'mouseover', _hoverGenerator, EventWrapper
.defineEvent 'hout', 'mouseover', _houtGenerator, EventWrapper