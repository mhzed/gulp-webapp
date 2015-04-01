fs = require "fs"
path = require "path"
through = require("through2")
gulp = require "gulp"
gulpFileDst = require "gulp-filedst"
minifyCSS = require('gulp-minify-css');
minifyJs = require('gulp-uglify');
less = require('gulp-less');

minFile = (fp)->
  ext = path.extname(fp)
  path.dirname(fp) + "/" + path.basename(fp, ext) + ".min" + ext
# takes gulp-line output, look for attr.gulp, then build accordingly
# the stream is then piped through without change
module.exports = (dstBaseDir)->
  _memory = {}
  through.obj (attr, unused, cb)->
    if not attr.gulp then return cb(null, attr)   # pass lines through
    srcfile = path.join(attr.basedir,attr.relative)
    if srcfile of _memory then return cb()  # continue, drop attr cuz it's duplicate
    _memory[srcfile] = 1
    pipe = gulp.src srcfile
    dst = gulp.dest path.dirname(path.join(dstBaseDir,attr.relative))
    for task,param of attr.gulp
      switch task
        when 'min'
          mfile = minFile(srcfile)
          if fs.existsSync(mfile)   # if already minified, why waste cpu?
            pipe = gulp.src mfile
          else
            if attr.href
              minifier = minifyCSS()
            else
              minifier = minifyJs()
            pipe = pipe.pipe(minifier)
        when 'less'
          pipe = pipe.pipe(less())
        when 'cp'
          pipe = pipe # noop, simply pass to destination
        when 'cat'
          # when concat, destination changes
          dst = gulpFileDst path.join(dstBaseDir,param)
        when 'skip'
          dst = through.obj() # null destination
        else
          console.log "Ignore unknow task #{task}"
    pipe.pipe(dst).on 'finish', ()->cb(null, attr)
