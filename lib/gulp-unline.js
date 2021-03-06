// Generated by CoffeeScript 1.8.0
(function() {
  var fs, path, through;

  fs = require("fs");

  path = require("path");

  through = require("through2");

  module.exports = function() {
    var catMemory;
    catMemory = {};
    return through.obj(function(o, unused, cb) {
      var line;
      if (o.gulp) {
        if (!('skip' in o.gulp)) {
          line = o._line.replace(/[ \t]gulp=["'][^"']*["']/, '');
          if ('cat' in o.gulp) {
            if (!(o.gulp.cat in catMemory)) {
              catMemory[o.gulp.cat] = 1;
              this.push(line.replace(o._link, o.gulp.cat));
            }
          } else {
            this.push(line);
          }
        }
      } else {
        this.push(o);
      }
      return cb();
    });
  };

}).call(this);

//# sourceMappingURL=gulp-unline.js.map
