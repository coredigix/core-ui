###*
 * Add/remove classes depending on events
###
if typeof document.addEventListener is 'function'
	document.addEventListener 'scroll', (
		->
			$body.toggleClass 'scrolled', scrollY isnt 0
			return
	),
		capture: on
		passive: yes