###*
 * Default submit controllers
###
_submitSendData= (type)->
	(event)->
		try
			# Loading
			$f= $ this
			$progress= $f.find('.progress:first')
			$progressTrack= $progress.find '.track:first'
			# hide errors
			$f.find('.form-error').addClass('h')
			# send to ajax
			vl=await Core.post
				data: this
				url: @action
				type: type
				upload: (event)->
					if event.lengthComputable
						$progressTrack.css 'width', "#{event.loaded*100/event.total}%"
					$progress.removeClass 'loading'
					return
			# when error
			vl= vl.json()
			throw vl if vl.error
			if vl.url
				Core.goto vl.url
			else
				$done= $f.find('.form-done').removeClass 'h'
				$done= $('<div class="alert success form-done">').appendTo $f unless $done.length
				$done.text vl.message if vl.message
		catch err
			$err= $f.find('.form-error').removeClass 'h'
			$err= $('<div class="alert danger form-error">').appendTo $f unless $err.length
			$err.text err and (err.error or error.message) or i18n?.internalError or 'internal Error'
		finally
			$progress?.addClass('loading')
		return

Core
# Upload form data via ajax as multipart data
.vSubmit 'multipart', _submitSendData 'multipart'
.vSubmit 'json', _submitSendData 'json'