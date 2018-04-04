var gulp = require('gulp'),
    stylus = require('gulp-stylus'),
    autoprefixer = require('autoprefixer-stylus'),
    jshint = require('gulp-jshint'),
    zip = require('gulp-zip');

var package = require('./package.json');


gulp.task('stylus', function() {
    gulp.src('css/*.styl')
    .pipe(stylus({
        use: [autoprefixer()]
    }))
    .pipe(gulp.dest('css/'));
});

gulp.task('lint', function() {
	return gulp.src('./js/handlers.js')
	.pipe(jshint(
        {
            'eqeqeq': true,
            'latedef': 'nofunc',
            'shadow': false,
            'undef': true
        }
    ))
	.pipe(jshint.reporter('default'))
});

gulp.task('zip', function() {
    gulp.src(['**',
            '!node_modules', '!node_modules/**',
            '!dist', '!dist/**'])
        .pipe(zip((package.name + '-' + package.version).replace(/[\s\.]/g, '-') + '.zip'))
        .pipe(gulp.dest('dist'));
});

gulp.task('watch', function() {
    gulp.watch('**/*.styl', ['stylus']);
});

gulp.task('default', ['stylus', 'watch']);
