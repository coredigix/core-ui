gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
PluginError		= gulp.PluginError
cliTable		= require 'cli-table'
template		= require 'gulp-template'
pug				= require 'gulp-pug'
through 		= require 'through2'
path			= require 'path'
sass			= require 'gulp-sass'
PKG				= require './package.json'
rmEmptyLines	= require 'gulp-remove-empty-lines'

settings =
	rootDir: __dirname.replace /\\/g, '/'
	PKG: PKG
	mode: if gutil.env.mode is 'prod' then 'prod' else 'dev'

# compile js (background, popup, ...)
compileCoffee = ->
	gulp.src "assets-js/index.coffee"
		.pipe include hardFail: true
		.pipe rmEmptyLines()
		.pipe template settings
		
		.pipe coffeescript(bare: true).on 'error', errorHandler
		.pipe rename "#{PKG.name}.#{PKG.version}.js"
		.pipe gulp.dest "build"
		.on 'error', errorHandler

compileSass = ->
	gulp.src "assets-css/index.sass"
		# .pipe include hardFail: true
		# .pipe rmEmptyLines()
		# .pipe rename "css-include.sass"
		# .pipe gulp.dest "build"

		# .pipe template settings
		# .pipe rename "css-template.sass"
		# .pipe gulp.dest "build"

		.pipe rename "#{PKG.name}.#{PKG.version}.sass"
		.pipe sass(
			if settings.mode is 'prod'
				outputStyle: 'compressed'
			else
				outputStyle: 'compact'
				# outputStyle: 'expanded'
		).on 'error', errorHandler
		.pipe rmEmptyLines()
		.pipe gulp.dest "build"
		.on 'error', errorHandler

compileDocPug= ->
	gulp.src "assets-doc/**/[^_]*.pug"
		.pipe pug self: true, data: settings
		.pipe gulp.dest "doc"
		.on 'error', errorHandler

# compile
watch = ->
	gulp.watch 'assets-js/**/*.coffee', compileCoffee
	gulp.watch ['assets-css/**/*.sass', 'assets-css/**/*.scss'], compileSass
	gulp.watch 'assets-doc/**/*.pug', compileDocPug
	return

# create default task
gulp.task 'default', gulp.series ( gulp.parallel compileCoffee, compileSass, compileDocPug ), watch

# error handler
errorHandler= (err)->
	# get error line
	expr = /:(\d+):(\d+):/.exec err.stack
	if expr
		line = parseInt expr[1]
		col = parseInt expr[2]
		code = err.code?.split("\n")[line-3 ... line + 3].join("\n")
	else
		code = line = col = '??'
	# Render
	table = new cliTable()
	table.push {Name: err.name},
		{Filename: err.filename||''},
		{Message: err.message||''},
		{Line: line||0},
		{Col: col||0}
	console.error table.toString()
	console.log '\x1b[31mStack:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', err.stack
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	console.log '\x1b[31mCode:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', code
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	return
