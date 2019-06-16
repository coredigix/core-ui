# Carousel
Core.addAction 'click', 'carousel-tumb', ->
	$item= $(this).addClass 'active'
	$item.siblings().removeClass 'active'
	$items= $item.closest('.v-carousel, .carousel').find('>.items')
	# active item
	$target= $items.children()[$item.index()]
	if $target
		$items[0].scrollTo $target.offsetLeft, 0
	return

# enbale carousel
_carouselSwipThumbEffectApply= (ele, prcent)->
	ele= ele.style
	ele['box-shadow']=	"0 #{3*prcent}px 3px white"
	ele.transform=		"translate(0, -#{5*prcent}px)"
	return
_carouselSwipThumbEffect= (event)->
	carouselWith= @offsetWidth
	i= @scrollLeft/carouselWith
	# get carousel
	thumbDiv= this.parentNode.querySelector '.thumbs'
	return unless thumbDiv
	# apply first element
	a= Math.floor i
	prcent= 1- i+a
	eleA= thumbDiv.children[a]
	_carouselSwipThumbEffectApply eleA, prcent
	# second element
	a= Math.ceil i
	prcent= 1-a+i
	eleB= thumbDiv.children[a]
	_carouselSwipThumbEffectApply eleB, prcent
	# active class
	return
Core.enableCarousel= (container)->
	# mobile carousel
	$carousel= $ '.carousel>.items', container
	$carousel.on 'scroll', _carouselSwipThumbEffect
	return