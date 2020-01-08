###*
 * hover
###
# Core.addEvent 'hover', 'mouseover', 
_customEvents.hover= [
	'mouseover'
	(listener, selector)->
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
]

###*
 * hover
###
# Core.addEvent 'hout', 'mouseover', (listener, selector)->
_customEvents.hout= [
	'mouseover'
	(listener, selector)->
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
]