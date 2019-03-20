var GfwCompiler, PKG, coffeescript, compileCoffee, compileDocPug, compileSass, gulp, include, isProd, path, pug, rename, sass, settings, through, uglify, watch;

gulp = require('gulp');

// gutil			= require 'gulp-util'
// minify		= require 'gulp-minify'
include = require("gulp-include");

rename = require("gulp-rename");

coffeescript = require('gulp-coffeescript');

pug = require('gulp-pug');

through = require('through2');

path = require('path');

sass = require('gulp-sass');

PKG = require('./package.json');

uglify = require('gulp-uglify-es').default;

// settings
isProd = false;

settings = {
  isProd: isProd,
  // infos
  rootDir: __dirname.replace(/\\/g, '/'),
  PKG: PKG
};

GfwCompiler = require('gridfw-compiler');

// compile js (background, popup, ...)
compileCoffee = function() {
  return gulp.src("assets-js/index.coffee").pipe(include({
    hardFail: true
  })).pipe(GfwCompiler.template(settings).on('error', GfwCompiler.logError)).pipe(coffeescript({
    bare: true
  }).on('error', GfwCompiler.logError)).pipe(rename(`${PKG.name}.js`)).pipe(gulp.dest("build")).on('error', GfwCompiler.logError);
};

compileSass = function() {
  // .pipe include hardFail: true
  // .pipe rmEmptyLines()
  // .pipe rename "css-include.sass"
  // .pipe gulp.dest "build"

  // .pipe template settings
  // .pipe rename "css-template.sass"
  // .pipe gulp.dest "build"
  return gulp.src("assets-css/index.sass").pipe(rename(`${  // .pipe rename "#{PKG.name}.#{PKG.version}.sass"
PKG.name}.sass`)).pipe(sass({
    outputStyle: 'compact'
  }).on('error', GfwCompiler.logError)).pipe(gulp.dest("build")).on('error', GfwCompiler.logError);
};

// compile doc views
compileDocPug = function() {
  var _flshFx, _trFx, files, viewsPath;
  // check for available views
  viewsPath = [];
  files = []; // keep all files until stream finished
  _trFx = function(file, enc, cb) {
    viewsPath.push(file.relative.replace(/\.pug$/, '.html'));
    files.push(file); // keep the file untill all finished
    cb(null);
  };
  _flshFx = function(cb) {
    var file, i, len;
    for (i = 0, len = files.length; i < len; i++) {
      file = files[i];
      this.push(file);
    }
    cb();
  };
  // return gulp
  // check for available views
  // compiles views
  return gulp.src("assets-doc/**/[^_]*.pug").pipe(through.obj(_trFx, _flshFx)).pipe(pug({
    self: true,
    data: {
      links: viewsPath,
      ...settings
    }
  })).pipe(gulp.dest("doc")).on('error', GfwCompiler.logError);
};

// compile
watch = function(cb) {
  if (!isProd) {
    gulp.watch('assets-js/**/*.coffee', compileCoffee);
    gulp.watch(['assets-css/**/*.sass', 'assets-css/**/*.scss'], compileSass);
    gulp.watch('assets-doc/**/*.pug', compileDocPug);
  }
  cb();
};

// create default task
gulp.task('default', gulp.series(gulp.parallel(compileCoffee, compileSass, compileDocPug), watch));

// check for avialable views
