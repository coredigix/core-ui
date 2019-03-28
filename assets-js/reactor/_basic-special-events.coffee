### CUSTOM EVENT WRAPPER ###
class customEventWrapper extends EventWrapper
	constructor: (originalEvent, eventName, currentTarget)->
		super originalEvent, eventName, currentTarget
		return



###*
 * Hover: call once pointer enters the element
###
_evHoverGen= (listner)->
	houtFlag= Symbol 'hover flag'
	(event)->
		unless @[hoverFlag]
			listner.call this, new customEventWrapper event, 'hover', this
			@[hoverFlag]= true
			# out listener to put flag to false
			outListener= (evnt2)=>
				unless _hasElement evnt2, this
					@[hoverFlag]= no
					window.removeEventListener 'mouseover', outListener, true
				return
			window.addEventListener 'mouseover', outListener, true
BASIC_SPECIAL_EVENTS.hover= ['mouseover', _evHoverGen]

###*
 * Hout: called once pointer quit the element
###
_evHoutGen= (listener)->
	houtFlag= Symbol 'hout flag'
	->
		unless @[houtFlag]
			@[houtFlag]= true
			# out listener to put flag to false
			outListener= (evnt2)=>
				unless _hasElement evnt2, this
					@[houtFlag]= no
					window.removeEventListener 'mouseover', outListener, true
					listner.call this, new customEventWrapper event, 'hout', this
				return
			window.addEventListener 'mouseover', outListener, true
BASIC_SPECIAL_EVENTS.hout= ['mouseover', _evHoverGen]

###*
 * Move
 * Movestart
 * Moveends
 * Those events are dispatched on elements, so we can just use theme like native ones
###
_moveEvent= (evnt, eventName)->
	new MouseEvent eventName,
		bubbles: on
		cancelable: true
		view: window
		which: 1
		shiftKey: evnt.shiftKey
		altKey: evnt.altKey
		ctrlKey: evnt.ctrlKey
		timeStamp: evnt.timeStamp
		clientX: evnt.clientX
		clientY: evnt.clientY
# [isFirstMoving, originalX, originalY, lastX, lastY, lastTimeStamp, dx, dy, dt]
_moveData = null
_moveMouseDown= (event)->
	# accept only left button
	return unless event.which is 1
	# mousemove
	mousemove = (evnt)=>
		x = evnt.clientX
		y = evnt.clientY
		tme= evnt.timeStamp
		if _moveData
			_moveData[6] = x - _moveData[3]
			_moveData[7] = y - _moveData[4]
			_moveData[8] = tme - _moveData[5]
		else
			_moveData = [yes, x, y, x, y, tme, 0, 0, 0]
			return
		# trigger move starts
		if _moveData[0]
			_moveData[0] = no
			event.target.dispatchEvent _moveEvent evnt, 'movestart'
		# trigger move
		event.target.dispatchEvent _moveEvent evnt, 'move'
		# set new values
		_moveData[3] = x
		_moveData[4] = y
		_moveData[5] = tme
		return
	window.addEventListener 'mousemove', mousemove, true
	# mouseup
	mouseUp = (evnt)=>
		window.removeEventListener 'mousemove', mousemove, true
		# trigger move ends
		if _moveData
			unless _moveData[0]
				event.target.dispatchEvent _moveEvent evnt, 'moveend'
			_moveData = null
		return
	window.addEventListener 'mouseup', mouseUp, {once: true, capture: true}
	return
window.addEventListener 'mousedown', _moveMouseDown, true

### move event wrapper ###
class MoveEventWrapper extends EventWrapper
	constructor: (event, eventName, currentTarget)->
		super  event, eventName, currentTarget
		# calc
		x = event.clientX
		y = event.clientY
		tme= event.timeStamp
		_defineProperties this,
			timeStamp: value: tme
			originalX: value: _moveData[1]
			originalY: value: _moveData[2]
			# lastX: value: _moveData[3]
			# lastY: value: _moveData[4]
			x: value: x
			y: value: y
			dx: value: _moveData[6]
			dy: value: _moveData[7]
			dt: value: _moveData[8]
		return

_moveListenerGen= (listener)-> listener
BASIC_SPECIAL_EVENTS.move= ['move', _moveListenerGen, MoveEventWrapper]
BASIC_SPECIAL_EVENTS.movestart= ['movestart', _moveListenerGen, MoveEventWrapper]
BASIC_SPECIAL_EVENTS.moveend= ['moveend', _moveListenerGen, MoveEventWrapper]