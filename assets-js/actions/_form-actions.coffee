### FORM ACTIONS ###
# F_FILES_LIST= Symbol 'selected files' # Moved to top to be used with ajax (will replace files)
# change callback
_fileUploadChange= (event)->
	# empty list if only one file is allowed
	$preview= $('~.files-preview', this)
	return unless $preview.length
	fileLst= @[F_FILES_LIST] ?= []
	unless @multiple
		$preview.empty()
		fileLst.splice 0
	# TODO: add max size: d-max-size="10mb"
	# max accepted files count
	if @hasAttribute 'd-max-count'
		maxCount= +@getAttribute 'd-max-count'
		maxCount= Infinity if isNaN maxCount
	else
		maxCount= Infinity
	# add file fx
	addFile= (file)->
		# check this file not already in the queue
		for f in fileLst
			return if (f.name is file.name) and (f.size is file.size) and (f.lastModified is file.lastModified)
		# add to queue
		fileLst.push file
		# preview
		ele= (Components._ 'filePreview', name: file.name).children[0]
		ele[F_FILES_LIST]= fileLst
		$preview.append ele
		# render if image
		if file.type?.startsWith 'image/'
			reader = new FileReader()
			reader.onload= (evnt)->
				el2= (Components._ 'filePreview', src: evnt.target.result).children[0]
				el2[F_FILES_LIST]= fileLst
				$el2= $ el2
				# remove on click on close
				$el2.find('.close').click (event)->
					$el2.remove()
					for f, i in fileLst
						if f is file
							fileLst.splice i, 1
							break
					return
				# append
				$(ele).replaceWith el2
				return
			reader.readAsDataURL file
		return
	# loop
	for file in @files
		if fileLst.length >= maxCount
			Core.alert i18n.fileUploadNbrExceeds nbr: maxCount
			break
		addFile file
	return

# file upload: add previews
Core.addAction 'click', 'file-upload', (event)->
	inputName= @getAttribute 'fileUploader'
	throw new Error "Expected attribute <fileUploader> for <file-upload>" unless inputName
	throw new Error "Expected input button for <file-upload>" unless @.tagName.toUpperCase() is 'INPUT'
	# get/create input file
	inpFile= @form[inputName]
	unless inpFile
		inpFile= document.createElement 'input'
		inpFile.name= inputName
		inpFile.type= 'file'
		inpFile.style.display= 'none'
		@form.appendChild inpFile
	# reset files
	inpFile.value= ''
	# set on change
	$ inpFile
		.one 'change', _fileUploadChange
		.click()
	return

