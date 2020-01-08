###*
 * Resize
###
window.addEventListener 'resize', ->
	document.documentElement.style.setProperty '--vh', "#{window.innerHeight}px"
	return