
# execute event once css transition finished
jQuery.fn.transitionOnce= (cb)-> @one 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', cb.bind this
# execute event once css animation finished
jQuery.fn.animationOnce= (cb)-> @one 'webkitAnimationEnd oanimationend msAnimationEnd animationend', cb.bind this