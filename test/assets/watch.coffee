console.log '---- test watch'
# create reactor instance
reactor= new Reactor()
reactor.watch '.btn.dada',
	click: (event)->
		console.log '---- data cliked: ', this
	# mouseover:
	# 
	# 
console.log '---- define zone'
reactor.watch '.zone',
	click: (event)->
		console.log '---- zone clicked: ', event.target
	mouseover: (event)-> console.log '---- mouseover:'
	mouseout: (event)-> console.log '---- mouseout:'
	hover: (event)-> console.log '---HOVER'
	hout: (event)-> console.log '---HOUT'
	moveStart: (event)-> console.log "--->> MOVE starts: (#{event.x}, #{event.y}) delta: (#{event.dx}, #{event.dy})"
	moveEnd: (event)-> console.log "--->> MOVE ends: (#{event.x}, #{event.y}) delta: (#{event.dx}, #{event.dy})"
	move: (event)-> console.log "--->> MOVE: (#{event.x}, #{event.y}) delta: (#{event.dx}, #{event.dy})"