# format HTML when inserting
Core.format= (parent)->
	parent ?= document.body
	# format date-time
	_dateProcess parent
	# adjust tab indicator
	_adjustTabIndicator parent
	return