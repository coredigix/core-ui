###*
 * Add/remove classes depending on events
###
# _toggleScrolledClass= ->
# 	$body.toggleClass 'scrolled', scrollY isnt 0
# 	return
# # add if supported
# if typeof document.addEventListener is 'function'
# 	document.addEventListener 'scroll', _toggleScrolledClass,
# 		capture: on
# 		passive: yes
# # exec
# do _toggleScrolledClass