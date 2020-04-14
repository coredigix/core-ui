###*
 * Files actions
###
ROOT_COMPONENT.addAction 'click', 'file-upload', (event)->
	try
		throw "Missing a form as parent" unless form= @closest 'form'
		throw "Missing attribute [fileUploader]" unless inputName= @getAttribute 'fileUploader'
		throw "Expected input file: #{inputName}" unless (inpFile= form[inputName]) and inpFile.type is 'file'
		# reset files
		inpFile.value= ''
		# set on change
		$(inpFile)
			.once 'change', _fileUploadChange
			.click()
	catch err
		component= _closestComponent(this)
		component.emit 'form-error',
			element:	this
			form:		form
			component:	component
			error:		err
	return


###*
 * File upload change
###
_fileUploadChange= (event)->
	# Get component
	component= _closestComponent this
	try
		# File list
		if fileLst= @[F_FILES_LIST]
			fileLst.splice 0 unless @multiple
		else
			fileLst= @[F_FILES_LIST]= []
		# add files
		for file in @files
			# continue if file already selected
			for f in fileLst
				continue if (f.name is file.name) and (f.size is file.size) and (f.lastModified is file.lastModified)
			# add to queue
			fileLst.push file
		# Preview fx
		if attr= @getAttribute 'd-preview'
			previewFx= component[attr]
			throw "Missing method: #{attr}" unless typeof previewFx is 'function'
		else
			previewFx= component.filePreview
		# Make previews
		previewFx.call this, @files, fileLst
	catch err
		component.emit 'form-error',
			element:	this
			form:		@form
			component:	component
			error:		err
	return