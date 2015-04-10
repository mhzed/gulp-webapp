fs = require "fs"
path = require "path"
byline = require("byline")
through = require("through2")
pAttrs = require "./parseAttrs"

# turns gulp src vfile stream into string line stream, script link tags with gulp attrs are turned
# into attr object
module.exports = ()->
  through.obj (vfile, unused, cb)->
    fs.createReadStream vfile.path
    .pipe new (byline.LineStream)()
    .pipe through.obj (line, unused, cb)=>
      line = line + "\n"
      if (m = /<(?:script|link)[ \t]+(.*?)[ \t]*\/?>/.exec line)
        attrs = pAttrs.parse(pAttrs.reTagAttr, m[1].toString())
        if attrs.gulp
          attrs.gulp = pAttrs.parse(pAttrs.reGulp, attrs.gulp)
          attrs._vfile = {
            path: vfile.path
            base: vfile.path.slice(0, vfile.path.length - vfile.relative.length)
          }
          attrs._link = attrs.src or attrs.href
          attrs._line = line.toString()
          @push attrs
        else
          @push line
      else
        @push line
      cb()
    .on 'finish', cb
