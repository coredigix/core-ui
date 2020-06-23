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

# [isFirstMoving, originalX, originalY, lastX, lastY, lastTimeStamp, dx, dy, dt, currentElement]
_moveData = null
_moveAddEventListenerOptions= {capture:true, passive: true}
_moveMouseDown= (event)->
	# accept only left button
	return unless event.which is 1
	eventTarget= event.target
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
			_moveData = [yes, x, y, x, y, tme, 0, 0, 0, eventTarget]
			return
		# trigger move starts
		if _moveData[0]
			_moveData[0] = no
			eventTarget.dispatchEvent _moveEvent evnt, 'movestart'
		# trigger move
		eventTarget.dispatchEvent _moveEvent evnt, 'move'
		# set new values
		_moveData[3] = x
		_moveData[4] = y
		_moveData[5] = tme
		return
	window.addEventListener 'mousemove', mousemove, _moveAddEventListenerOptions
	# mouseup
	mouseUp = (evnt)=>
		window.removeEventListener 'mousemove', mousemove, _moveAddEventListenerOptions
		window.removeEventListener 'mouseup', mouseUp, _moveAddEventListenerOptions
		# trigger move ends
		if _moveData
			unless _moveData[0]
				eventTarget.dispatchEvent _moveEvent evnt, 'moveend'
			_moveData = null
		return
	window.addEventListener 'mouseup', mouseUp, _moveAddEventListenerOptions
	return
window.addEventListener 'mousedown', _moveMouseDown, _moveAddEventListenerOptions

# Add touch support to move event
_moveTouch= (event)->
	touches= event.changedTouches
	return unless touches.length is 1 # accept only one touch
	# OP
	evnt= touches[0]
	x = evnt.clientX
	y = evnt.clientY
	tme= event.timeStamp
	if _moveData
		_moveData[6] = x - _moveData[3]
		_moveData[7] = y - _moveData[4]
		_moveData[8] = tme - _moveData[5]
	else
		_moveData = [yes, x, y, x, y, tme, 0, 0, 0, event.target]
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
_moveTouchEnd= (event)->
	if _moveData
		unless _moveData[0]
			_moveData[9].dispatchEvent _moveEvent event, 'moveend'
		_moveData = null
	return
window.addEventListener 'touchmove', _moveTouch, _moveAddEventListenerOptions
window.addEventListener 'touchend', _moveTouchEnd, _moveAddEventListenerOptions

###*
 * Move event wrapper
###
class MoveEventWrapper extends EventWrapper
	constructor: (isSync, eventName, customEvent, event, eventPath, currentTarget, component, target)->
		super isSync, eventName, customEvent, event, eventPath, currentTarget, component, target
		# private attributes
		@originalX	= _moveData[1]
		@originalY	= _moveData[2]
		@dx			= _moveData[6]
		@dy			= _moveData[7]
		@dt			= _moveData[8]
		return

# Add
ROOT_COMPONENT
.defineEvent 'move', 'move', null, MoveEventWrapper
.defineEvent 'movestart', 'movestart', null, MoveEventWrapper
.defineEvent 'moveend', 'moveend', null, MoveEventWrapper
