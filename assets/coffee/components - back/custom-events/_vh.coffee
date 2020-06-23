###*
 * Adjust vertical height (usefull for mobile)
###
_windowResizeListener= ->
	# Check for mobile menu
	vh= window.innerHeight
	if mn= document.querySelector('.vh-min')
		vh-= mn.offsetHeight
		console.log 'vh: ', vh
	document.documentElement.style.setProperty '--vh', "#{vh}px"
	return
window.addEventListener 'resize', _windowResizeListener, {passive: yes}
do _windowResizeListener