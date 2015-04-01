fs = require "fs"
path = require "path"
through = require("through2")
bna = require "bna"

# If you want to send html to client, for SEO, then you must render react during build time

# takes gulp-unline output, scan for string marker, tries to render React to html and embed
# at marker's position
# marker:  the string marker in html
# reactSrcFile: js file that must export a React class (v0.13), not factory
# headerCode: what to require for server side to execute the code?
module.exports = (marker, reactSrcFile, headerCode)->
  through.obj (line, unused, cb)->
    if line.indexOf(marker) != -1
      [src] = bna.fuse reactSrcFile, path.dirname(reactSrcFile), 'PageClass', {prependCode: headerCode}
      thisStream = @
      do ->   # create a scope for eval
        React = require "react"   # of course
        old = process.cwd()
        process.chdir path.dirname(reactSrcFile)
        `eval(src)`
        Page = React.createFactory(@PageClass)
        thisStream.push React.renderToString Page()
        process.chdir old
    else
      @push line
    cb()