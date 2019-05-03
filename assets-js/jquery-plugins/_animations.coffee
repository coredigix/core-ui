# flip cards
jQuery.fn.flipCard= (options)->
	options ?= {}
	@each (i, el)->
		$dv= $ el
		# get first child
		$innerCard= $dv.children().eq(0)
		$sides= $innerCard.children()
		$frontSide= $sides.eq 0
		$backSide= $sides.eq 1
		# fix sides height
		frontHeight= $frontSide.removeClass('h').height()
		backHeight= $backSide.removeClass('h').height()
		$dv.css height: Math.max frontHeight, backHeight
		# add styles
		$dv.addClass 'flip-card'
		$innerCard.addClass 'flip-card-inner'
		$frontSide.addClass 'flip-card-side'
		$backSide.addClass 'flip-card-side-back'
		# transition event
		$innerCard.transitionOnce ->
			$dv.removeClass 'flip-card'
			$innerCard.removeClass 'flip-card-inner run'
			$frontSide.removeClass 'flip-card-side'
			$backSide.removeClass 'flip-card-side-back'
			$dv.css height: 'auto'
			# target
			isFront= options.side is 'front'
			$frontSide.toggleClass 'h', !isFront
			$backSide.toggleClass 'h', isFront
			return
		# start animation
		$innerCard.addClass 'run'
		return
	return this
	