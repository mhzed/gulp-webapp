fs = require "fs"
path = require "path"
through = require("through2")

# undo gulp-line,
# output is ready to be written to file
module.exports = ()->
  catMemory = {}
  through.obj (o, unused, cb)->
    if o.gulp
      if not ('skip' of o.gulp)
        line = o._line.replace(/[ \t]gulp=["'][^"']*["']/, '')  # remove gulp attribute
        if 'cat' of o.gulp
          if not (o.gulp.cat of catMemory)  # deal with cat target once
            catMemory[o.gulp.cat] = 1
            @push line.replace o._link,o.gulp.cat  # replace src with cat src
        else
          @push line # pipe through
    else
      @push o
    cb()
