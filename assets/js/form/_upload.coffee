###*
 * File upload
###
Core.addAction 'click', 'file-upload', (event)->
	try
		throw "Missing attribute [fileUploader]" unless inputName= @getAttribute 'fileUploader'
		throw "Missing a form as parent" unless form= @closest 'form'
		throw "Missing input file: #{inputName}" unless inpFile= form[inputName]
		throw "Expected input file: #{inputName}" unless inpFile.type is 'file'
		# reset files
		inpFile.value= ''
		# set on change
		$(inpFile)
			.one 'change', _fileUploadChange
			.click()
	catch err
		err= new Error "File upload>> #{err}" if typeof err is 'string'
		throw err
	return

###*
 * File upload change
###
_fileUploadChange= (event)->
	# Preview fx
	if attr= @getAttribute 'd-preview'
		previewFx= Core[attr]
		throw new Error "Expected function: Core.#{attr}" unless typeof previewFx is 'function'
	else
		previewFx= Core.filePreview
		return unless typeof previewFx is 'function'
	# Empty list if only one file is allowed
	$preview= $(this).closest('.f-cntrl').find('.files-preview')
	return unless $preview.length
	# File list
	fileLst= @[F_FILES_LIST] ?= []
	unless @multiple
		$preview.empty()
		fileLst.splice 0
	# add file fx
	addFile= (file)->
		# check this file not already in the queue
		for f in fileLst
			return if (f.name is file.name) and (f.size is file.size) and (f.lastModified is file.lastModified)
		# add to queue
		fileLst.push file
		# preview
		filePreview= previewFx file
		if typeof filePreview is 'string'
			dv= document.createElement 'div'
			dv.className="inline-block"
			dv.innerHTML= filePreview
			filePreview= dv
		filePreview[F_FILES_LIST]= file
		$preview.append filePreview
		# render if image
		# if file.type?.startsWith 'image/'
		# 	reader = new FileReader()
		# 	reader.onload= (evnt)->
		# 		el2= (Components._ 'filePreview', src: evnt.target.result).children[0]
		# 		el2[F_FILES_LIST]= fileLst
		# 		$el2= $ el2
		# 		# remove on click on close
		# 		$el2.find('.close').click (event)->
		# 			$el2.remove()
		# 			for f, i in fileLst
		# 				if f is file
		# 					fileLst.splice i, 1
		# 					break
		# 			return
		# 		# append
		# 		$(filePreview).replaceWith el2
		# 		return
		# 	reader.readAsDataURL file
		return
	# loop
	for file in @files
		addFile file
	return


###*
 * Do operatio before submit
###
_doResizeImagesItem= (files, file, i, isResizeMax, width, height, fit)->
	try
		# Load image
		img=Core.image(file)
		# Resize
		if isResizeMax
			img.resizeMax width, height
		else
			img.resize width, height
		# Fit
		img.fit fit if fit
		# Position
		img.position 0.5, 0.5
		# get file
		file2= await img.toFile()
		# replace file
		files[i]= file2 if file2.size < file.size
	catch err
		Core.fatalError 'submit', err
	return
_doResizeImages= (input, isResizeMax, WxH, fit)->
	# do operations
	jobs= []
	if window.Blob? and (files=input[Core.F_FILES_LIST] or files=input.files) # has window Blob
		# get width and height
		return unless WxH
		WxH= WxH.split 'x'
		width= parseInt v if v=WxH[0]
		height= parseInt v if v=WxH[1]
		# Loop
		for file, i in files
			if file.type in ['image/jpeg', 'image/png']
				jobs.push _doResizeImagesItem files, file, i, isResizeMax, width, height, fit
			else
				console.warn "Ignore mimeType: #{file.type}"
	return Promise.all jobs
Core
	.vSubmit 'resize', (WxH, fit)-> _doResizeImages this, no, WxH, fit
	.vSubmit 'resizeMax', (WxH, fit)-> _doResizeImages this, yes, WxH, fit

