var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var sourcemaps = require('gulp-sourcemaps');
var path = require('path');

gulp.task('hubot', function() {
  gulp.src('./node_modules/hubot/**/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({ bare: true })
    .on('error', gutil.log))
    .pipe(sourcemaps.write('.', {sourceRoot: path.resolve(__dirname + '/node_modules/hubot/')}))
    .pipe(gulp.dest('./dest/hubot/'));
});

gulp.task('coffee', function() {
  gulp.src('./src/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({ bare: true })
    .on('error', gutil.log))
    .pipe(sourcemaps.write('.', {sourceRoot: path.resolve(__dirname + '/src/')}))
    .pipe(gulp.dest('./dest/'));
});

gulp.task('default', ['coffee']);