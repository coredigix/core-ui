###*
 * File preview
###
filepreview: (addedFiles, allFiles, args)->
	# Find preview container
	$preview= $(this).closest('.f-cntrl').find('.files-preview')
	$preview.empty() unless @multiple
	# Add previews
	for file in addedFiles
		fileData= await _readFile file
		filePreview= _toHTMLElement Core.html.filePreview {file: file, data: fileData}
		filePreview[F_FILES_LIST]= file
		$preview.append filePreview
	return
###*
 * File preview as background image
###
background: (addedFiles, allFiles, args)->
	if file= addedFiles[0]
		selector= ':scope '+args.slice(1).join(' ')
		fileData= await _readFile file
		@closest('.f-cntrl').querySelector(selector).style.backgroundImage= "url(#{fileData})"
	return
###*
 * Image resize
###
doResizeImages: do->
	# do resize of each file
	_doResizeImagesItem= (input, component, files, file, i, type, width, height, fit)->
		try
			# Load image
			img=Core.image(file)
			# Resize
			switch type
				when 'resize'
					img.resize width, height
				when 'resizeMax'
					img.resizeMax width, height
				else
					throw new Error "Unsupported type: #{type}"
			# Fit
			img.fit fit if fit
			# Position
			img.position 0.5, 0.5
			# get file
			file2= await img.toFile()
			# replace file
			files[i]= file2 if file2.size < file.size
		catch err
			component.emit 'error',
				element: input
				form: input.form
				component: component
				error: err
		return
	# Interface
	return (component, input, type, WxH, fit)->
		jobs= []
		if window.Blob? and (files=input[F_FILES_LIST] or input.files) # has window Blob
			# get width and height
			return unless WxH
			WxH= WxH.split 'x'
			width= parseInt v if v=WxH[0]
			height= parseInt v if v=WxH[1]
			# Loop
			for file, i in files
				if file.type in ['image/jpeg', 'image/png']
					jobs.push _doResizeImagesItem input, component, files, file, i, type, width, height, fit
				else
					Core.warn "Ignore mimeType: #{file.type}"
		return Promise.all jobs