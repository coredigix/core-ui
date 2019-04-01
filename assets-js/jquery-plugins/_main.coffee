###
# jQuery addons
###
# execute event once css transition finished
jQuery.fn.transitionOnce= (e)-> this.one 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', e.bind this
# execute event once css animation finished
jQuery.fn.animationOnce= (e)-> this.one 'webkitAnimationEnd oanimationend msAnimationEnd animationend', e.bind this