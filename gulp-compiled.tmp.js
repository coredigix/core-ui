/**
 * Gulp file
 */
var EventStream, GridfwGulp, Gulp, GulpClone, GulpCoffeescript, Include, Rename, compileCoreJS, compiler, htmlComponentsTask, params;

GridfwGulp = require('../gulp-gridfw');

// GridfwGulp= require 'gulp-gridfw'
Gulp = require('gulp');

compiler = new GridfwGulp(Gulp, {
  isProd: false,
  delay: 500
});

// # ::::::::::::::
// Through2=		require 'through2'

// INCLUDE PRECOMPILER PARAMS
params = {
  /** PARAMS */
  version: require('./package.json').version,
  isProd: false
};


// COMPILRE HTML COMPONENTS
Include = require('gulp-include');

GulpCoffeescript = require('gulp-coffeescript');

GulpClone = require('gulp-clone');

Rename = require('gulp-rename');

EventStream = require('event-stream');

htmlComponentsTask = function() {
  return Gulp.src('assets/html-components/**/*.pug', {
    nodir: true
  }).pipe(compiler.onError()).pipe(compiler.precompile(params)).pipe(compiler.pugPipeCompiler(false, {
    globals: ['i18n', 'window', 'Core'],
    inlineRuntimeFunctions: false
  })).pipe(compiler.joinComponents({
    target: 'components.js',
    template: 'Core.html'
  // .pipe compiler.minifyJS()
  })).pipe(Gulp.dest('tmp/'));
};

compileCoreJS = function() {
  var dest, glp, glp1, glp2, result;
  dest = 'build/';
  glp = Gulp.src('assets/core-ui.coffee', {
    nodir: true
  }).pipe(compiler.onError()).pipe(Include({
    hardFail: true
  })).pipe(compiler.precompile(params)).pipe(GulpCoffeescript({
    bare: true
  }));
  // Babel
  if (false) {
    glp1 = glp.pipe(GulpClone()).pipe(compiler.minifyJS()).pipe(Gulp.dest(dest));
    glp2 = glp.pipe(GulpClone()).pipe(compiler.babel()).pipe(compiler.minifyJS()).pipe(Rename(function(path) {
      path.basename += '-babel';
    })).pipe(Gulp.dest(dest));
    result = EventStream.merge([glp1, glp2]);
  } else {
    result = glp.pipe(compiler.minifyJS()).pipe(Gulp.dest(dest));
  }
  return result;
};

// Other compilers
/**
 * COMPILE API FILES
 */
// .js
// 	name:	'API>> Compile Coffee files'
// 	src:	'assets/core-ui.coffee'
// 	dest:	'build/'
// 	watch:	['assets/core-ui.coffee', 'assets/coffee/**/*.coffee', 'assets/ui-components/**/*.coffee']
// 	data:	params
// 	babel:	false
/** Copy static files */
module.exports = compiler.addTask('API>> Compile Coffee files', ['assets/core-ui.coffee', 'assets/coffee/**/*.coffee', 'assets/ui-components/**/*.coffee', 'assets/html-components/**/*.pug'], Gulp.series(htmlComponentsTask, compileCoreJS)).copy({
  name: 'API>> Copy static files',
  src: 'assets/lib/**/*',
  dest: 'build/'
// Compile sass
}).sass({
  name: 'API>> Compile Sass files',
  src: 'assets/core-ui.sass',
  dest: 'build/',
  watch: ['assets/core-ui.sass', 'assets/sass/**/*.sass']
}).sass({
  name: 'API>> Compile Sass files',
  src: 'assets/themes/*.sass',
  dest: 'build/themes',
  watch: 'assets/themes/**/*.sass'
});
