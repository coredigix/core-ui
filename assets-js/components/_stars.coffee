# rating stars
_starCalcValue= (el, x)->
	step= +el.getAttribute 'd-step'
	step= 0 if isNaN(step)
	rect= el.getBoundingClientRect()
	x= (x - rect.x) * 100 / rect.width
	if x < 0
		x=0
	else if x > 100
		x= 100
	else
		if step
			x= Math.round(x / step) * step
		else
			x= Math.round x
	return x
Core.addAction 'mousemove', 'starRating', (event)->
	el= event.currentTarget
	x= _starCalcValue el, event.x
	# save value
	x2= x + '%'
	bullet= el.querySelector('.star-bullet')
	if bullet
		bullet.setAttribute 'd-value', x2
		bullet.style.left= "calc(#{x2} - 1.25em)"
	starMv=el.querySelector('.star-mv')
	starMv?.style.width= x2
	# level
	level= el.getAttribute 'd-levels'
	if level
		level= ~~(x/+level)
		bullet?.setAttribute 'd-level', level
		starMv?.setAttribute 'd-level', level
	return
.addAction 'click', 'starRating', (event)->
	el= event.currentTarget
	x= _starCalcValue el, event.x
	# save
	el.setAttribute 'd-value', x
	el.querySelector('.star-front')?.style.width= x + '%'
	# set input value
	el.querySelector('input')?.value= x
	# level
	level= el.getAttribute 'd-levels'
	if level
		el.setAttribute 'd-level', ~~(x/+level)
	return