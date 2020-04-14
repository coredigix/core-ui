###*
 * Minify images when upload
###
image: do ->
	###*
	 * Fit logic
	 * @return [0, sx, sy, sw, sh, dx, dy, dw, dh]
	###
	_imageProcessFit=
		###*
		 * Contain
		###
		contain: (dWidth, dHeight, naturalWidth, naturalHeight)->
			# traget ratio is begger then source ratio : fix width
			if dWidth/dHeight < naturalWidth/naturalHeight
				dw= dWidth
				dh= naturalHeight* dWidth/naturalWidth
				dx= 0
				dy= @_positionY dHeight, dh
			# else: fix height
			else
				dw= naturalWidth * dWidth/naturalHeight
				dh= dHeight
				dy=0
				dx= @_positionX dWidth, dw
			# return value
			[0, 0, 0, naturalWidth, naturalHeight, dx, dy, dw, dh]
		###*
		 * Cover
		###
		cover: (dWidth, dHeight, naturalWidth, naturalHeight)->
			# traget ratio is begger then source ratio : fix height
			if dWidth/dHeight >= naturalWidth/naturalHeight
				sw= naturalWidth
				sh= dHeight * naturalWidth/dWidth
				# sh= naturalHeight * dWidth/dHeight
				sx= 0
				sy= @_positionY naturalHeight, sh
			# else: fix width
			else
				sw= dWidth * naturalHeight/dHeight
				sh= naturalHeight
				# sw= naturalWidth * dHeight/dWidth
				sx= @_positionX naturalWidth, sw
				sy= 0
			# return value
			[0, sx, sy, sw, sh, 0, 0, dWidth, dHeight]
		###*
		 * fill
		###
		fill: (dWidth, dHeight, naturalWidth, naturalHeight)-> [0, 0, 0, naturalWidth, naturalHeight, 0, 0, dWidth, dHeight]
	###*
	 * Read file
	###
	_imageProcessReadFile= (file)->
		new Promise (res, rej)->
			reader = new FileReader()
			reader.onload = (e)-> res e.target.result
			reader.onerror= rej
			reader.readAsDataURL file
			return
	# CLASS
	class ImageProcess
		constructor: (data)->
			@_data= data
			@_canvas= null
			@_fit= _imageProcessFit.cotnain # default fit
			return
		###*
		 * Resize image
		###
		resize: (width, height)->
			@_canvas= null
			@_width= width
			@_height= height
			@_max= no # if do resizeMax or resize
			this # chain
		###*
		 * Resize to maximum value
		###
		resizeMax: (width, height)->
			@_canvas= null
			@_width= width
			@_height= height
			@_max= yes # if do resizeMax or resize
			this # chain
		###*
		 * Position
		 * @example
		 * position(0, 0) # TOP Left
		 * position(0.5, 0.5) # middle
		 * position(1, 1) # bottom right
		 * position(0, 1) bottom left
		 * position(0.5) = position(0.5, 0.5)
		###
		position: (dx, dy)->
			@_canvas= null
			@_positionX= (containerWidth, imgWidth)-> dx * (containerWidth-imgWidth)
			@_positionY= (containerHeight, imgHeight)-> dy * (containerHeight-imgHeight)
			this # chain
		###*
		 * Fit
		 * @example
		 * fit('cover')	# default value
		 * fit('contain')
		 * fit('fill')
		 * fit('inside')
		###
		fit: (fit)->
			throw new Error "Unknown fit option: #{fit}" unless fitfx= _imageProcessFit[fit]
			@_canvas= null
			@_fit= fitfx
			this # chain
		###*
		 * Build canvas and merge image
		 * @return {Promise}
		###
		_build: ->
			imageData= @_data
			# Read file
			imageData= await _imageProcessReadFile imageData unless typeof imageData is 'string'
			# resize image and get canvas
			return new Promise (res, rej)=>
				img= new Image()
				canvas= @_canvas= document.createElement 'canvas'
				img.onload= =>
					try
						# get image natural size
						naturalWidth= img.naturalWidth
						naturalHeight= img.naturalHeight
						# target width and height
						targetWidth= @_width
						targetHeight= @_height
						if targetWidth>0
							unless targetHeight>0
								targetHeight= targetWidth * naturalHeight/naturalWidth
						else
							throw 'Resize info missing!' unless targetHeight>0
							targetWidth= targetHeight * naturalWidth/naturalHeight
						# get fit info
						# [0, sx, sy, sw, sh, dx, dy, dw, dh]
						fitArr= @_fit targetWidth, targetHeight, naturalWidth, naturalHeight
						# canvas size
						if @_max
							# canvas size
							canvasWidth= fitArr[7]
							canvasHeight= fitArr[8]
							sw= fitArr[3]
							sh= fitArr[4]
							# fix target width
							if sw < canvasWidth
								canvasHeight= sh * canvasWidth/canvasHeight
								canvasWidth= sw
							else if sh < canvasHeight
								canvasWidth= sw * canvasHeight/canvasWidth
								canvasHeight= sh
							fitArr[7]= canvasWidth
							fitArr[8]= canvasHeight
							fitArr[5]= fitArr[6]= 0
						else
							canvasWidth= targetWidth
							canvasHeight= targetHeight
						# adjust canvas
						canvas.width= canvasWidth
						canvas.height= canvasHeight
						# fill white
						canvasCtx= canvas.getContext '2d'
						canvasCtx.fillStyle= 'white'
						canvasCtx.fillRect 0, 0, canvasWidth, canvasHeight
						# draw image
						fitArr[0]= img
						canvasCtx.drawImage.apply canvasCtx, fitArr
						res canvas
					catch err
						rej err
					return
				img.onerror= rej
				img.src= imageData
				return
		###*
		 * Export
		###
		toDataURL: (mimeType, quality)->
			# build canvas
			await @_build() unless @_canvas
			return @_canvas.toDataURL (mimeType or @_data.type), quality
		toBlob: (mimeType, quality)->
			# build canvas
			await @_build() unless @_canvas
			# convert to blob
			return new Promise (res, rej)=>
				@_canvas.toBlob res, (mimeType or @_data.type), quality
				return
		toFile: (mimeType, quality, name)->
			blob= await @toBlob(mimeType, quality)
			return new File [blob], name or @_data.name
	# INTERFACE
	return (file)-> new ImageProcess file