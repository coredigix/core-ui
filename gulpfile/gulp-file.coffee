###*
 * Gulp file
###
GridfwGulp= require '../gulp-gridfw'
# GridfwGulp= require 'gulp-gridfw'
Gulp= require 'gulp'

compiler= new GridfwGulp Gulp,
	isProd: <%= isProd %>


# # ::::::::::::::
# Include=		require 'gulp-include'
# GulpCoffeescript= require 'gulp-coffeescript'
# Through2=		require 'through2'

# INCLUDE PRECOMPILER PARAMS
params=
	#=include ../precompiler-params.coffee

compiler
	###*
	 * COMPILE API FILES
	###
	# .addTask 'debug js', ['assets/core-ui.coffee', 'assets/coffee/**/*.coffee'], ->
	# 	return Gulp.src 'assets/core-ui.coffee', nodir: yes
	# 		.pipe compiler.onError()
	# 		.pipe Include hardFail: true
	# 		.pipe compiler.precompile(params)
	# 		# .pipe GulpCoffeescript bare: true
	# 		.pipe Gulp.dest 'build/'
	.js
		name:	'API>> Compile Coffee files'
		src:	'assets/core-ui.coffee'
		dest:	'build/'
		watch:	['assets/core-ui.coffee', 'assets/coffee/**/*.coffee', 'assets/ui-components/**/*.coffee']
		data:	params
		babel:	<%- isProd %>
	###* Copy static files ###
	.copy
		name:	'API>> Copy static files'
		src:	'assets/lib/**/*'
		dest:	'build/'
	# Compile sass
	.sass
		name:	'API>> Compile Sass files'
		src:	'assets/core-ui.sass'
		dest:	'build/'
		watch:	['assets/core-ui.sass', 'assets/sass/**/*.sass']
	.sass
		name:	'API>> Compile Sass files'
		src:	'assets/themes/*.sass'
		dest:	'build/themes'
		watch:	'assets/themes/**/*.sass'

	###*
	 * COMPILE WEBSITE
	###
	.js
		name:	'Compile Coffee files'
		src:	'assets-website/app/**/[^_]*.coffee'
		dest:	'build-website/app/'
		watch:	'assets-website/app/**/*.coffee'
		data:	params
	.copy
		name:	'Copy static files'
		src:	'assets-website/lib/**/*'
		dest:	'build-website/lib/'
	###* Compile i18n for server ###
	.i18n
		name:	'Compile server side i18n'
		src:	['assets-website/i18n/commons/**/*.coffee', 'assets-website/i18n/server/**/*.coffee']
		dest:	'build-website/i18n/'
		data:	params
	###* Compile views ###
	.views
		name:	'Compile views'
		src:	'assets-website/views/**/*.pug'
		i18n:	['assets-website/i18n/commons/**/*.coffee', 'assets-website/i18n/precompiled-views/**/*.coffee']
		dest:	'build-website/views/'
		modifiedOnly: yes
		data:	params
	###**********
	* PUBLIC	*
	**********###
	# Copy static files
	.copy
		name:	'Copy public static files'
		src:	['assets-website/public/lib/**/*', 'build/**/*']
		dest:	'build-website/public/'
	# Compile JS for client
	.js
		name:	'Compile client side JS'
		src:	'assets-website/public/js/[!_]*.coffee'
		watch:	'assets-website/public/js/**/*.coffee'
		dest:	'build-website/public/'
		data:	params
		babel:	<%= isProd %>
	# Compile sass
	.sass
		name:	'Compile Sass files'
		src:	'assets-website/public/css/[^_]*.sass'
		dest:	'build-website/public/'
		watch:	'assets-website/public/css/**/*.sass'
	# Compile i18n for client side
	.i18n
		name:	'Compile client side i18n'
		src:	['assets-website/i18n/commons/**/*.coffee', 'assets-website/i18n/browser/**/*.coffee']
		dest:	'build-website/public/i18n/'
		data:	params
		varname:'window.i18n'	# varname used client side
	# Minify images and make webp equivalent
	.webp
		name:	'Process images'
		src:	'assets-website/public/images/**/*'
		dest:	'build-website/public/images/'
	# Create favicons
	.favicon
		name:	'Process favicon'
		src:	'assets-website/public/favicon.svg'
		dest:	'build-website/public/'
		icons:	[384, 192, 152, 144, 128, 96, 72, 64, 48]
	# Compile json files
	.json
		name:	'Process JSON'
		src:	'assets-website/public/json/[^_]*.coffee'
		dest:	'build-website/public/'
		watch:	'assets-website/public/json/**/*.coffee'
	# SEO
	.seo
		name:	'process SEO'
		robots:	'assets-website/public/seo/robots.txt'
		sitemap:'assets-website/public/seo/sitemap.pug'
		dest:	'build-website/public/'
		data:	params
	# Run tasks
	.run()