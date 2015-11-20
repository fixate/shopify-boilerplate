# Gulp
gulp       = require "gulp"
cache      = require "gulp-cache"
coffee     = require "gulp-coffee"
concat     = require "gulp-concat"
exec       = require "gulp-exec"
imagemin   = require "gulp-imagemin"
minifyCSS  = require "gulp-minify-css"
plumber    = require "gulp-plumber"
remember   = require "gulp-remember"
rename     = require "gulp-rename"
replace    = require "gulp-replace"
rev        = require "gulp-rev"
sass       = require "gulp-sass"
sourcemaps = require "gulp-sourcemaps"
shell      = require "gulp-shell"
uglifyJs   = require "gulp-uglify"
gutil      = require "gulp-util"
watch      = require "gulp-watch"

browserSync  = require "browser-sync"
cp           = require "child_process"
extend       = require "extend"
moment       = require "moment"
pngquant     = require "imagemin-pngquant"
reload       = browserSync.reload
runSequence  = require("run-sequence").use(gulp)
spawn        = cp.spawn

pkg  = require "./package.json"
conf = require "./gulpconfig.json"





#*-------------------------------------*\
# $RELOAD
#*-------------------------------------*/
gulp.task 'bs-reload', () ->
  reload()



#*------------------------------------*\
#     $SASS
#*------------------------------------*/
gulp.task "sass", () ->
  gulp.src(["#{conf.path.dev.scss}/shopify.{scss,sass}"])
    .pipe plumber(conf.plumber)
    .pipe sass({errLogToConsole: true})
    .pipe rename(
      basename: "style"
      extname: ".css.liquid"
    )
    .pipe gulp.dest(conf.path.prod.assets)






#--------------------------------------------------------
# Minify CSS
#--------------------------------------------------------
gulp.task "minify:css", () ->
  return gulp.src(["#{conf.path.prod.assets}/style.css"])
    .pipe(minifyCSS())
    .pipe(gulp.dest("#{conf.path.prod.assets}"))



#*------------------------------------*\
#     $PIXEL &
#     $VECTOR OPTIM
#*------------------------------------*/
gulp.task 'imagemin', () ->
  files = ['jpg', 'jpeg', 'png', 'svg'].map (ext) ->
    "#{conf.path.dev.img}/**/*.#{ext}"

  return gulp.src(files)
    .pipe cache(imagemin {
      optimizationLevel: 3,
      progressive: true,
      interlaced: true,
      svgoPlugins: [
        { removeViewBox: false },
        { removeUselessStrokeAndFill: false },
        { removeEmptyAttrs: false }
      ],
      use: [pngquant()]
    })
    .pipe rename(dirname: "")
    .pipe gulp.dest conf.path.prod.assets





#*------------------------------------*\
#     $AUTO RELOAD GULPFILE ON SAVE
#     noxoc.de/2014/06/25/reload-gulpfile-js-on-change/
#*------------------------------------*/
gulp.task "auto_reload", () ->
  process = undefined
  restart = () ->
    if process != undefined
      process.kill()
    process = spawn 'gulp', ['default'], {stdio: 'inherit'}

  gulp.watch 'gulpfile.coffee', restart
  restart()





#*------------------------------------*\
#     $COFFEE
#*------------------------------------*/
gulp.task "coffee", () ->
  gulp.src ["#{conf.path.dev.coffee}/**/*.coffee"]
    .pipe plumber(conf.plumber)
    .pipe cache(coffee({bare: true}).on('error', gutil.log))
    .pipe remember()
    .pipe gulp.dest(conf.path.dev.js)
    .pipe reload({stream: true})
  return




#*------------------------------------*\
#     $CONCAT JS
#*------------------------------------*/
gulp.task "concat", ["coffee"], () ->
  gulp.src [
    "#{conf.path.dev.js}/lib/toggler.js"
    "#{conf.path.dev.js}/main.js"
  ]
    .pipe concat('built.js')
    .pipe gulp.dest(conf.path.prod.assets)


#--------------------------------------------------------
# Minify JS
#--------------------------------------------------------
gulp.task "uglify:js", () ->
  return gulp.src(["#{conf.path.prod.assets}/built.js"])
    .pipe uglifyJs()
    .pipe gulp.dest("#{conf.path.prod.assets}")



#*------------------------------------*\
#     $WATCH
#*------------------------------------*/
gulp.task "watch", ["sass", "coffee", 'imagemin', "font", 'shopify:dev'], () ->
  gulp.watch "#{conf.path.dev.scss}/**/*.scss", ["sass"]
  gulp.watch "#{conf.path.dev.js}/coffee/**/*.coffee", ["concat"]

  imageFiles = ['jpg', 'jpeg', 'png', 'svg'].map (ext) ->
    "#{conf.path.dev.img}/**/*.#{ext}"
  gulp.watch imageFiles, ["imagemin"]

  fontFiles = ['eot', 'woff', 'ttf', 'svg'].map (curr) ->
    "#{conf.path.dev.fnt}/**/*#{curr}"
  gulp.watch fontFiles, ["font"]





#*------------------------------------*\
#     $FONT REV
#*------------------------------------*/
gulp.task "font", () ->
  files = ['eot', 'woff', 'woff2', 'ttf', 'svg'].map (curr) ->
    "#{conf.path.dev.fnt}/**/*#{curr}"

  gulp.src(files)
    .pipe rename(dirname: "")
    .pipe gulp.dest(conf.path.prod.assets)





#*------------------------------------*\
#     $REV REPLACE
#     github.com/jamesknelson/gulp-rev-replace/issues/23
#*------------------------------------*/
gulp.task 'rev_replace', ["uglify", "minify", "font", "imagemin"], () ->
  manifest = require "./#{conf.path.dev.assets}/rev-manifest.json"
  stream = gulp.src ["./#{conf.path.prod.assets}/#{manifest['style.css']}"]

  Object.keys(manifest).reduce((stream, key) ->
    stream.pipe replace(key, manifest[key])
  , stream)
    .pipe gulp.dest("./#{conf.path.prod.assets}")





#*------------------------------------*\
#     $UPDATE NPM DEPS
#*------------------------------------*/
gulp.task 'update_deps', shell.task 'npm-check-updates -u'





#*------------------------------------*\
#     $SHOPIFY THEME UPLOAD
#*------------------------------------*/
themeKit = (cmd, env) ->
  options =
    continueOnError: false
    pipeStdout: true

  themeCmd = [
    "theme #{cmd} --env #{env}"
    "assets/*",
    "layout/*",
    "locales/*",
    "snippets/*",
    "templates/*.liquid",
  ].join(' ')

  gulp.src('src/').pipe(exec("cd src/ && #{themeCmd}", options))
  return

gulp.task 'shopify:dev', () ->
  themeKit('watch', 'development')

gulp.task 'shopify:prod', () ->
  themeKit('upload', 'production')





#*------------------------------------*\
#     $TASKS
#*------------------------------------*/
gulp.task 'default', ['watch', 'shopify:dev']

gulp.task 'build', () ->
  runSequence "sass", "minify:css", "coffee", "concat", "uglify:js", "shopify:prod"
