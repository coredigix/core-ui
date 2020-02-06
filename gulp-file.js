var Babel, CoffeescriptNode, CsOptions, GfwCompiler, HTML_REPLACE, PKG, Path, SassNode, baseURL, coffeescript, compileCoffee, compileDocI18n, compileDocJS, compileDocViews, compileSass, copyFonts, doccCpyPublic, gulp, include, isProd, path, port, pug, rename, sass, settings, through, uglify, viewSettings, watch;

gulp = require('gulp');

Path = require('path');

// gutil			= require 'gulp-util'
// minify		= require 'gulp-minify'
include = require("gulp-include");

rename = require("gulp-rename");

coffeescript = require('gulp-coffeescript');

CoffeescriptNode = require('coffeescript');

pug = require('gulp-pug');

through = require('through2');

path = require('path');

sass = require('gulp-sass');

SassNode = require('node-sass');

PKG = require('./package.json');

uglify = require('gulp-uglify-es').default;

Babel = require('gulp-babel');

// settings
isProd = true;

port = 3001;

baseURL = `http://localhost:${port}/`;

settings = {
  isProd: isProd,
  // infos
  rootDir: __dirname.replace(/\\/g, '/'),
  PKG: PKG,
  baseURL: baseURL,
  basePATH: (new URL(baseURL)).pathname,
  port: port
};

// settings for views
CsOptions = {
  bare: false,
  header: false,
  sourceMap: false,
  sourceRoot: false
};

HTML_REPLACE = {
  '>': '&gt;',
  '<': '&lt;',
  '\'': '&#039;',
  '"': '&quot;',
  '&': '&amp;'
};

viewSettings = {
  pretty: !isProd,
  filters: {
    text: function(txt, options) {
      return txt.replace(/([<>&"'])/g, function(_, c) {
        return HTML_REPLACE[c];
      });
    },
    coffeescript: function(txt, options) {
      return CoffeescriptNode.compile(txt, CsOptions);
    },
    sass: function(txt, options) {
      return SassNode.renderSync({
        data: txt,
        indentedSyntax: true,
        indentType: 'tab',
        outputStyle: 'compressed'
      });
    }
  }
};

if (isProd) {
  viewSettings.debug = false;
}

GfwCompiler = require('gridfw-compiler');

// compile js (background, popup, ...)
compileCoffee = function() {
  return gulp.src("assets/js/index.coffee").pipe(include({
    hardFail: true
  })).pipe(GfwCompiler.template(settings).on('error', GfwCompiler.logError)).pipe(coffeescript({
    bare: true
  }).on('error', GfwCompiler.logError)).pipe(rename(`${PKG.name}.js`)).pipe(Babel({
    presets: ['babel-preset-env'],
    plugins: [
      [
        'transform-runtime',
        {
          helpers: false,
          polyfill: false,
          regenerator: false
        }
      ],
      'transform-async-to-generator'
    ]
  // plugins: ['@babel/transform-runtime']
  })).pipe(uglify({
    compress: {
      toplevel: false,
      keep_infinity: true,
      warnings: true
    }
  })).pipe(gulp.dest("build")).on('error', GfwCompiler.logError);
};

compileSass = function() {
  // .pipe include hardFail: true
  // .pipe rmEmptyLines()
  // .pipe rename "css-include.sass"
  // .pipe gulp.dest "build"

  // .pipe template settings
  // .pipe rename "css-template.sass"
  // .pipe gulp.dest "build"
  return gulp.src("assets/css/index.sass").pipe(rename(`${  // .pipe rename "#{PKG.name}.#{PKG.version}.sass"
PKG.name}.sass`)).pipe(sass({
    outputStyle: 'compressed'
  }).on('error', GfwCompiler.logError)).pipe(gulp.dest("build")).on('error', GfwCompiler.logError);
};

// compile doc views
compileDocJS = function() {
  return gulp.src("assets/doc/*.coffee").pipe(include({
    hardFail: true
  })).pipe(GfwCompiler.template(settings).on('error', GfwCompiler.logError)).pipe(coffeescript({
    bare: true
  }).on('error', GfwCompiler.logError)).pipe(Babel({
    presets: ['babel-preset-env'],
    plugins: [
      [
        'transform-runtime',
        {
          helpers: false,
          polyfill: false,
          regenerator: false
        }
      ],
      'transform-async-to-generator'
    ]
  // plugins: ['@babel/transform-runtime']
  })).pipe(uglify({
    compress: {
      toplevel: false,
      keep_infinity: true,
      warnings: true
    }
  })).pipe(gulp.dest("doc")).on('error', GfwCompiler.logError);
};

// copy fonts
copyFonts = function() {
  return gulp.src('assets/fonts/*').pipe(gulp.dest("build/fonts")).on('error', GfwCompiler.logError);
};

// compile i18n
compileDocViews = function() {
  return gulp.src(['assets/doc/i18n/views/**/*.coffee'], {
    nodir: true
  }).pipe(coffeescript({
    bare: true
  // .pipe gulp.dest 'tmp/pre-i18n/'
  // replace i18n inside views
  })).pipe(GfwCompiler.i18n({
    base: Path.resolve(__dirname, 'assets/doc/views/'),
    views: 'assets/doc/views/**/*.pug', // compile to those views
    data: settings
  // save to tmp
  })).pipe(gulp.dest('tmp/views/')).pipe(GfwCompiler.waitForAll()).pipe(GfwCompiler.views(viewSettings)).pipe(uglify({
    module: true,
    compress: {
      toplevel: true,
      module: true,
      keep_infinity: true,
      warnings: true
    }
  })).pipe(gulp.dest('doc/views/')).on('error', GfwCompiler.logError);
};

// compile i18n server side
compileDocI18n = function() {
  return gulp.src(['assets/doc/i18n/server/**/*.coffee'], {
    nodir: true
  }).pipe(coffeescript({
    bare: true
  })).pipe(GfwCompiler.i18n()).pipe(uglify({
    module: true,
    compress: {
      toplevel: true,
      module: true,
      keep_infinity: true,
      warnings: true
    }
  })).pipe(gulp.dest('doc/i18n/')).on('error', GfwCompiler.logError);
};

doccCpyPublic = function() {
  return gulp.src(['assets/doc/public/**/*', 'build/*'], {
    nodir: true
  }).pipe(gulp.dest('doc/public/')).on('error', GfwCompiler.logError);
};

// compile
watch = function(cb) {
  if (!isProd) {
    gulp.watch('assets/js/**/*.coffee', compileCoffee);
    gulp.watch(['assets/css/**/*.sass', 'assets-css/**/*.scss'], compileSass);
    gulp.watch('assets/doc/*.coffee', compileDocJS);
    gulp.watch(['assets/doc/i18n/views/**/*.coffee', 'assets/doc/views/**/*.pug'], compileDocViews);
    gulp.watch('assets/doc/i18n/server/**/*.coffee', compileDocI18n);
    gulp.watch(['assets/doc/public/**/*', 'build/*'], doccCpyPublic);
    gulp.watch(['assets/fonts/*'], copyFonts);
  }
  cb();
};

// create default task
gulp.task('default', gulp.series(gulp.parallel(compileCoffee, compileSass, compileDocJS, compileDocViews, compileDocI18n, doccCpyPublic, copyFonts), watch));

// check for avialable views
