###*
 * Adjust vertical height (usefull for mobile)
###
_windowResizeListener= ->
	document.documentElement.style.setProperty '--vh', "#{window.innerHeight}px"
	return
window.addEventListener 'resize', _windowResizeListener, {passive: yes}