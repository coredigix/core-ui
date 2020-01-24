gulp			= require 'gulp'
Path			= require 'path'
# gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
CoffeescriptNode= require 'coffeescript'
pug				= require 'gulp-pug'
through 		= require 'through2'
path			= require 'path'
sass			= require 'gulp-sass'
SassNode		= require 'node-sass'
PKG				= require './package.json'

uglify			= require('gulp-uglify-es').default
Babel			= require 'gulp-babel'

# settings
isProd= <%= isProd %>
port= 3001
baseURL= "http://localhost:#{port}/"
settings =
	isProd: isProd
	# infos
	rootDir: __dirname.replace /\\/g, '/'
	PKG: PKG
	baseURL: baseURL
	basePATH: (new URL baseURL).pathname
	port:	port

<%
const uglfyExpNode= '.pipe uglify {module: on, compress: {toplevel: true, module: true, keep_infinity: on, warnings: on} }';
const uglfyExpBrowser= '.pipe uglify {compress: {toplevel: no, keep_infinity: on, warnings: on} }';
%>

# settings for views
CsOptions=
	bare: no
	header: no
	sourceMap: no
	sourceRoot: no
HTML_REPLACE=
	'>'	: '&gt;'
	'<'	: '&lt;'
	'\'': '&#039;'
	'"' : '&quot;'
	'&' : '&amp;'
viewSettings= 
	pretty: not isProd
	filters:
		text: (txt, options) -> txt.replace /([<>&"'])/g, (_, c)-> HTML_REPLACE[c]
		coffeescript: (txt, options)-> CoffeescriptNode.compile txt, CsOptions
		sass: (txt, options)-> SassNode.renderSync
			data: txt
			indentedSyntax: yes
			indentType: 'tab'
			outputStyle: <%= isProd ? "'compressed'": "'compact'" %>
viewSettings.debug= false if isProd

GfwCompiler		= require 'gridfw-compiler'

# compile js (background, popup, ...)
compileCoffee = ->
	gulp.src "assets/js/index.coffee"
		.pipe include hardFail: true
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		.pipe rename "#{PKG.name}.js"
		<% if(isProd){ %>
		.pipe Babel
			presets: ['babel-preset-env']
			plugins: [
				['transform-runtime',{
					helpers: no
					polyfill: no
					regenerator: no
				}]
				'transform-async-to-generator'
			]
			# plugins: ['@babel/transform-runtime']
		.pipe uglify {compress: {toplevel: no, keep_infinity: on, warnings: on} }
		<% } %>
		.pipe gulp.dest "build"
		.on 'error', GfwCompiler.logError

compileSass = ->
	gulp.src "assets/css/index.sass"
		# .pipe include hardFail: true
		# .pipe rmEmptyLines()
		# .pipe rename "css-include.sass"
		# .pipe gulp.dest "build"

		# .pipe template settings
		# .pipe rename "css-template.sass"
		# .pipe gulp.dest "build"

		.pipe rename "#{PKG.name}.sass"
		# .pipe rename "#{PKG.name}.#{PKG.version}.sass"
		.pipe sass( outputStyle: <%= isProd ? "'compressed'" : "'compact'" %>).on 'error', GfwCompiler.logError
		.pipe gulp.dest "build"
		.on 'error', GfwCompiler.logError

# compile doc views
compileDocJS= ->
	gulp.src "assets/doc/*.coffee"
		.pipe include hardFail: true
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		<% if(isProd){ %>
		.pipe Babel
			presets: ['babel-preset-env']
			plugins: [
				['transform-runtime',{
					helpers: no
					polyfill: no
					regenerator: no
				}]
				'transform-async-to-generator'
			]
			# plugins: ['@babel/transform-runtime']
		.pipe uglify {compress: {toplevel: no, keep_infinity: on, warnings: on} }
		<% } %>
		.pipe gulp.dest "doc"
		.on 'error', GfwCompiler.logError

# copy fonts
copyFonts= ->
	gulp.src 'assets/fonts/*'
		.pipe gulp.dest "build/fonts"
		.on 'error', GfwCompiler.logError

# compile i18n
compileDocViews= ->
	gulp.src ['assets/doc/i18n/views/**/*.coffee'], nodir: true
		.pipe coffeescript bare: true
		# .pipe gulp.dest 'tmp/pre-i18n/'
		# replace i18n inside views
		.pipe GfwCompiler.i18n
			base: Path.resolve __dirname, 'assets/doc/views/'
			views: 'assets/doc/views/**/*.pug' # compile to those views
			data: settings
		# save to tmp
		.pipe gulp.dest 'tmp/views/'
		.pipe GfwCompiler.waitForAll()
		.pipe GfwCompiler.views viewSettings
		<%= isProd ? uglfyExpNode : '' %>
		.pipe gulp.dest 'doc/views/'
		.on 'error', GfwCompiler.logError
# compile i18n server side
compileDocI18n = ->
	gulp.src ['assets/doc/i18n/server/**/*.coffee'], nodir: true
		.pipe coffeescript bare: true
		.pipe GfwCompiler.i18n()
		<%= isProd ? uglfyExpNode : '' %>
		.pipe gulp.dest 'doc/i18n/'
		.on 'error', GfwCompiler.logError

doccCpyPublic= ->
	gulp.src ['assets/doc/public/**/*', 'build/*'], nodir: true
		.pipe gulp.dest 'doc/public/'
		.on 'error', GfwCompiler.logError

# compile
watch = (cb)->
	unless isProd
		gulp.watch 'assets/js/**/*.coffee', compileCoffee
		gulp.watch ['assets/css/**/*.sass', 'assets-css/**/*.scss'], compileSass

		gulp.watch 'assets/doc/*.coffee', compileDocJS
		gulp.watch ['assets/doc/i18n/views/**/*.coffee', 'assets/doc/views/**/*.pug'], compileDocViews
		gulp.watch 'assets/doc/i18n/server/**/*.coffee', compileDocI18n
		gulp.watch ['assets/doc/public/**/*', 'build/*'], doccCpyPublic
		gulp.watch ['assets/fonts/*'], copyFonts
	cb()
	return

# create default task
gulp.task 'default', gulp.series ( gulp.parallel compileCoffee, compileSass, compileDocJS, compileDocViews, compileDocI18n, doccCpyPublic, copyFonts), watch


# check for avialable views
