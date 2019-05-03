# date
#=include _date.coffee

# format HTML
Core.format= (parent)->
	parent ?= document.body
	# format date-time
	_dateProcess parent
	return