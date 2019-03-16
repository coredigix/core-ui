gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
pug				= require 'gulp-pug'
through 		= require 'through2'
path			= require 'path'
sass			= require 'gulp-sass'
PKG				= require './package.json'

uglify			= require('gulp-uglify-es').default

# settings
isProd= gutil.env.hasOwnProperty('prod')
settings =
	mode: if isProd then 'prod' else 'dev'
	isProd: isProd
	# infos
	rootDir: __dirname.replace /\\/g, '/'
	PKG: PKG

GfwCompiler		= require if isProd then '../compiler' else 'gridfw-compiler'

# compile js (background, popup, ...)
compileCoffee = ->
	glp=gulp.src "assets-js/index.coffee"
		.pipe include hardFail: true
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		.pipe rename "#{PKG.name}.js"
		# .pipe rename "#{PKG.name}.#{PKG.version}.js"
	# if is prod
	if isProd
		glp = glp.pipe uglify()
	# dest
	glp.pipe gulp.dest "build"
		.on 'error', GfwCompiler.logError

compileSass = ->
	gulp.src "assets-css/index.sass"
		# .pipe include hardFail: true
		# .pipe rmEmptyLines()
		# .pipe rename "css-include.sass"
		# .pipe gulp.dest "build"

		# .pipe template settings
		# .pipe rename "css-template.sass"
		# .pipe gulp.dest "build"

		.pipe rename "#{PKG.name}.sass"
		# .pipe rename "#{PKG.name}.#{PKG.version}.sass"
		.pipe sass(
			outputStyle: if isProd then 'compressed' else 'compact'
		).on 'error', GfwCompiler.logError
		.pipe gulp.dest "build"
		.on 'error', GfwCompiler.logError

# compile doc views
compileDocPug= ->
	# check for available views
	viewsPath = []
	files = [] # keep all files until stream finished
	_trFx = (file, enc, cb)->
		viewsPath.push file.relative.replace /\.pug$/, '.html'
		files.push file # keep the file untill all finished
		cb null
		return
	_flshFx= (cb)->
		for file in files
			@push file
		cb()
		return
	# return gulp
	gulp.src "assets-doc/**/[^_]*.pug"
		# check for available views
		.pipe through.obj _trFx, _flshFx
		# compiles views
		.pipe pug self: true, data: {links: viewsPath, ...settings}
		.pipe gulp.dest "doc"
		.on 'error', GfwCompiler.logError

# compile
watch = (cb)->
	unless isProd
		gulp.watch 'assets-js/**/*.coffee', compileCoffee
		gulp.watch ['assets-css/**/*.sass', 'assets-css/**/*.scss'], compileSass
		gulp.watch 'assets-doc/**/*.pug', compileDocPug
	cb()
	return

# create default task
gulp.task 'default', gulp.series ( gulp.parallel compileCoffee, compileSass, compileDocPug ), watch


# check for avialable views
