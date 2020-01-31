Path= require 'path'


module.exports=
	### APP INFO ###
	name: 'Core-ui'
	email: 'contact@coredigix.com'
	author: 'coredigix.com'

	baseURL: '<%= baseURL %>'

	isProd: <%= isProd %>
	logLevel: <%= isProd ? "'debug'" : "'warn'" %>

	# listening
	port: <%= port %>
	protocol: 'http'

	trustProxy: (addr, level)-> level < 1

	# CACHE
	jsCacheMaxSize: <%= isProd? 20 * 2**20 : 0 %>
	jsCacheMaxSteps: 500
	
	# PLUGINS
	plugins:
		# cookies
		cookie:
			require: 'gridfw-cookie'
			secret: 'ck'
		# render
		render:
			require: 'gridfw-view-render'
			views: Path.join __dirname, 'views'
		# downloader
		downloader:
			require: 'gridfw-downloader'
			etag: true # add etag http header
			pretty: <%= !isProd %> # show json and xml in pretty format
			jsonp: (ctx)-> ctx.query.cb or 'callback' # jsonp callback name
		# uploader
		uploader:
			require: 'gridfw-uploader'
			timeout: 10 * 60 * 1000 # Upload timeout
			tmpDir: require('os').tmpdir() # where to store tmp files, default to os.tmp
			limits: # Upload limits
				size: 20 * (2**20) # Max body size (20M)
				fieldNameSize: 1000 # Max field name size (in bytes)
				fieldSize: 2**20 # Max field value size (default 1M)
				fields: 1000 # Max number of non-file fields
				fileSize: 10 * (2**20) # For multipart forms, the max file size (in bytes) (default 10M)
				files: 100 # For multipart forms, the max number of file fields
				parts: 1000 # For multipart forms, the max number of parts (fields + files) 
				headerPairs: 2000 # For multipart forms, the max number of header
		# server side i18N
		i18n:
			require: 'gridfw-i18n'
			mapper: Path.resolve __dirname, 'i18n/mapper.js'