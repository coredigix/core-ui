###* Progress ###
progress: (loaded, total)->
	$progress= @$progress or @element.find('.progress:first')
	$progressTrack= $progress.find '.track:first'
	if total is Infinity
		$progress.addClass 'loading'
	else
		$progress.removeClass 'loading'
		$progressTrack.css 'width', "#{loaded*100/total}%"
	return