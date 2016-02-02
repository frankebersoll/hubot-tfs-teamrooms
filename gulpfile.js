var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var sourcemaps = require('gulp-sourcemaps');
var path = require('path');

var sourceRoot = (dest, file) => {
  var output = path.join(dest, file.relative);
  var dir = path.dirname(output);
  return path.relative(dir, file.base);
};

gulp.task('hubot', function() {
  gulp.src('./node_modules/hubot/**/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({ bare: true })
    .on('error', gutil.log))
    .pipe(sourcemaps.write('.', {
      includeContent: false,
      sourceRoot: sourceRoot.bind(null, './dest/hubot/')
    }))
    .pipe(gulp.dest('./dest/hubot/'));
});

gulp.task('coffee', function() {
  gulp.src('./src/**/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({ bare: true })
    .on('error', gutil.log))
    .pipe(sourcemaps.write('.', {
      includeContent: false,
      sourceRoot: sourceRoot.bind(null, './dest/')
    }))
    .pipe(gulp.dest('./dest/'));
});

gulp.task('default', ['coffee']);