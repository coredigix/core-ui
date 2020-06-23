###*
 * Create popups
 * @param {HTMLElement} element - HTML element attached to popup
 * @param {Symbol} symb - Symbol used to check if popup already created
###
_popup: do->
	DOM_REMOVE_TIMEOUT= 1000 # timeout when close before removing from DOM
	# Create Popup
	_createPopup= (element, symb, margin, caret)->
		margin?= 10
		# Create popup
		popup= _toHTMLElement Core.html.popup({caret: caret})
		# Event listeners
		listenEscape= (event)->
			do result.close if event.keyCode is 27
			return
		listenClick= (event)->
			target= event.target
			do result.close unless target is element or target.closest('.popup') is popup
			return
		# Remove popup from DOM
		_rmDOMTmeout= null
		_removeDOM= ->
			_rmDOMTmeout= null
			element[symb]= null
			popup.parentNode?.removeChild popup
			return
		# Result
		result=
			$popup:	popup
			$body:	popup.querySelector '.popup-body'
			isBottom: yes # is bottom or top
			open: ->
				# Clear close timeout
				clearTimeout _rmDOMTmeout if _rmDOMTmeout
				_rmDOMTmeout= null
				# Add to DOM
				element.offsetParent.appendChild popup unless popup.parentNode
				element[symb]= result
				# Add event listeners
				document.addEventListener 'keyup', listenEscape, {capture: no, passive: yes}
				document.addEventListener 'click', listenClick, {capture: yes, passive: yes}
				# Adjust position
				do @adjust
				# class
				if @isBottom
					clAdd= 'popup-bottom'
					clRm='popup-up'
				else
					clAdd= 'popup-up'
					clRm='popup-bottom'
				# Animation
				clList= element.classList
				clList.remove clRm
				clList.add 'has-popup', clAdd
				# popup
				clList= popup.classList
				clList.remove 'anim-out', clRm
				clList.add 'anim-in', clAdd
				return
			close: ->
				# Animation
				clList= popup.classList
				clList.remove 'anim-in'
				clList.add 'anim-out'
				element.classList.remove 'has-popup', 'popup-up', 'popup-bottom'
				# Remove event listeners
				document.removeEventListener 'keyup', listenEscape, {capture: no, passive: yes}
				document.removeEventListener 'click', listenClick, {capture: yes, passive: yes}
				# Remove from DOM
				_rmDOMTmeout= setTimeout _removeDOM, DOM_REMOVE_TIMEOUT
				# Stop ajax
				@ajax?.abort()
				return
			###* Adjust position ###
			adjust: ->
				# Popup position
				popupStyle= popup.style
				popupStyle.left= "#{element.offsetLeft}px"
				popupStyle.top= "#{element.offsetTop+element.offsetHeight+margin}px"
				popupStyle.minWidth= "#{element.offsetWidth}px"
				# Do animation
				popup.classList.add 'anim-in'
				return
			# Falgs
			ajax: null # flag if this popup do ajax
		return result
	# Interface
	(element, symb, margin, caret)->
		unless result= element[symb]
			result= element[symb]= _createPopup element, symb, margin, caret
		return result