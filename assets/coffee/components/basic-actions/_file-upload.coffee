###*
 * Files actions
 * @example
 * 		action="fileUpload {inputFileName}"
###
fileUpload: do ->
	###*
	 * File upload change
	###
	_fileUploadChange= (event)->
		try
			input= event.target
			# File list
			if fileLst= input[F_FILES_LIST]
				fileLst.splice 0 unless input.multiple
			else
				fileLst= input[F_FILES_LIST]= []
			# add files
			for file in input.files
				# continue if file already selected
				for f in fileLst
					continue if (f.name is file.name) and (f.size is file.size) and (f.lastModified is file.lastModified)
				# add to queue
				fileLst.push file
			# Preview fx
			if fxName= input.getAttribute('d-preview').trim()
				args= fxName.split(/\s+/)
				fxName= args[0]
				previewFx= @[fxName]
				throw "Missing method: #{fxName}" unless typeof previewFx is 'function'
				previewFx.call this, input, input.files, fileLst, args
			# Default preview fx
			else
				@filePreview input, input.files, fileLst, []
		catch err
			@emit 'form-error',
				element:	this
				form:		input.form
				error:		err
		return
	# Interface
	return (event, args)->
		try
			throw "Missing <form> as parent" unless form= event.currentTarget.closest 'form'
			# Get input file
			throw "Missing input file name" unless inputName= args[1]
			throw "Expected input file: #{inputName}" unless (inpFile= form[inputName]) and inpFile.type is 'file'
			# reset files
			inpFile.value= ''
			# set on change
			$(inpFile)
				.one 'change', _fileUploadChange.bind this
				.click()

		catch err
			@emit 'error',
				element:	this
				form:		form
				error:		err
		return

###*
 * Default File preview
 * @example
 * 		d-preview="filePreview"	# Use default preview and lookup for '.files-preview' container
 * 		d-preview="filePreview cssSelector"	# lookup for 'cssSelector' container
 * 		d-preview="filePreview bg cssSelector"	# lookup for 'cssSelector' and change it's background
###
filePreview: (input, addedFiles, allFiles, args)->
	# Background image
	if args[1] is 'bg'
		if file= addedFiles[0]
			selector= args.slice(2).join(' ')
			fileData= await _readFile file
			$preview= $(input).closest('.f-cntrl').find(selector)
			$preview.css 'background-image': "url(#{fileData})"
	# Multiple images
	else
		selector= if args.length > 1 then args.slice(1).join(' ') else '.files-preview'
		# Find preview container
		$preview= $(input).closest('.f-cntrl').find(selector)
		$preview.empty() unless @multiple
		# Add previews
		for file in addedFiles
			fileData= await _readFile file
			filePreview= _toHTMLElement Core.html.filePreview {file: file, data: fileData}
			filePreview[F_FILES_LIST]= file
			$preview.append filePreview
	return
