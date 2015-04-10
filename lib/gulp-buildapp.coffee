fs = require "fs"
path = require "path"
through = require("through2")
gulp = require "gulp"
gulpFileDst = require "gulp-filedst"
minifyCSS = require('gulp-minify-css');
minifyJs = require('gulp-uglify');
less = require('gulp-less');
rename = require "gulp-rename"

minFile = (fp)->
  ext = path.extname(fp)
  path.dirname(fp) + "/" + path.basename(fp, ext) + ".min" + ext

resFile = (attr, rel)->
  if rel[0] == '/'
    srcfile = path.join attr._vfile.base, rel
    relative = rel.slice(1)
  else
    srcfile = path.resolve(path.dirname(attr._vfile.path), rel)
    relative = srcfile.slice(attr._vfile.base.length)
  [srcfile, relative]

# takes gulp-line output, look for attr.gulp, then build accordingly
# the stream is then piped through without change
module.exports = (dstBaseDir, opts)->
  _memory = {}
  through.obj (attr, unused, cb)->
    if not attr.gulp then return cb(null, attr)   # pass lines through
    [srcfile, relative ] = resFile(attr, attr._link)
    if srcfile of _memory then return cb()  # continue, drop attr cuz it's duplicate
                                            # possible if building multiple files pointing to same js/css
    _memory[srcfile] = 1
    pipe = gulp.src srcfile
    dst = gulp.dest path.dirname(path.resolve(dstBaseDir, relative))
    for task,param of attr.gulp
      switch task
        when 'min'
          mfile = minFile(srcfile)
          if fs.existsSync(mfile)   # if already minified, why waste cpu?
            pipe = gulp.src mfile
               .pipe rename(path.basename(srcfile)) # in dest dir, ".min" is removed from name
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
          do=>
            [fp, relative ] = resFile(attr, param)
            dst = gulpFileDst path.resolve(dstBaseDir,relative)
        when 'skip'
          dst = through.obj() # null destination
        else
          console.log "Ignore unknow task #{task}"
    pipe.pipe(dst).on 'finish', ()->cb(null, attr)
