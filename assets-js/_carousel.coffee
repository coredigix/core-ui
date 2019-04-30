# Carousel
Core.addAction 'click', 'carousel-tumb', ->
	$item= $(this).addClass 'active'
	$item.siblings().removeClass 'active'
	$items= $item.closest('.v-carousel').find('>.items')
	# active item
	$target= $items.children()[$item.index()]
	if $target
		$items[0].scrollTo $target.offsetLeft, 0
	return