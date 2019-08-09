###*
 * Steps
###
_stepsScroll= (el, inc)->
	stepEl= el.closest '.step'
	parentEl= stepEl.parentNode
	parentEl.scrollTo parentEl.scrollLeft+ inc*stepEl.offsetWidth, 0
	scrollTo 0, parentEl.offsetTop
	return
Core.addAction 'click', 'nextStep', -> _stepsScroll this, 1
Core.addAction 'click', 'previousStep', -> _stepsScroll this, -1