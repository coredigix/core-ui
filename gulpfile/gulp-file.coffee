###*
 * Gulp file
###
GridfwGulp= require '../gulp-gridfw'
# GridfwGulp= require 'gulp-gridfw'
Gulp= require 'gulp'

compiler= new GridfwGulp Gulp,
	isProd: <%- isProd %>
	delay: 500


# # ::::::::::::::
# Through2=		require 'through2'

# INCLUDE PRECOMPILER PARAMS
params=
	#=include ../precompiler-params.coffee

# COMPILRE HTML COMPONENTS
Include=		require 'gulp-include'
GulpCoffeescript= require 'gulp-coffeescript'
GulpClone=		require 'gulp-clone'
Rename=			require 'gulp-rename'
EventStream=	require 'event-stream'
htmlComponentsTask= ->
	Gulp.src 'assets/html-components/**/*.pug', nodir: yes
		.pipe compiler.onError()
		.pipe compiler.precompile(params)
		.pipe compiler.pugPipeCompiler(no, {globals: ['i18n', 'window', 'Core'], inlineRuntimeFunctions: no})
		.pipe compiler.joinComponents {target:'components.js', template: 'Core.html'}
		# .pipe compiler.minifyJS()
		.pipe Gulp.dest 'tmp/'
compileCoreJS= ->
	dest= 'build/'
	glp= Gulp.src 'assets/core-ui.coffee', nodir: yes
		.pipe compiler.onError()
		.pipe Include hardFail: true
		.pipe compiler.precompile(params)
		.pipe GulpCoffeescript bare: true
	# Babel
	if <%-isProd %>
		glp1= glp.pipe GulpClone()
			.pipe compiler.minifyJS()
			.pipe Gulp.dest dest
		glp2= glp.pipe GulpClone()
			.pipe compiler.babel()
			.pipe compiler.minifyJS()
			.pipe Rename (path)->
				path.basename += '-babel'
				return
			.pipe Gulp.dest dest
		result= EventStream.merge [glp1, glp2]
	else
		result= glp.pipe compiler.minifyJS()
			.pipe Gulp.dest dest
	return result

# Other compilers
module.exports= compiler
	###*
	 * COMPILE API FILES
	###
	.addTask 'API>> Compile Coffee files',
		['assets/core-ui.coffee', 'assets/coffee/**/*.coffee', 'assets/ui-components/**/*.coffee', 'assets/html-components/**/*.pug'],
		Gulp.series htmlComponentsTask, compileCoreJS
	# .js
	# 	name:	'API>> Compile Coffee files'
	# 	src:	'assets/core-ui.coffee'
	# 	dest:	'build/'
	# 	watch:	['assets/core-ui.coffee', 'assets/coffee/**/*.coffee', 'assets/ui-components/**/*.coffee']
	# 	data:	params
	# 	babel:	<%- isProd %>
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

	