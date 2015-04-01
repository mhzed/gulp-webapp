// Generated by CoffeeScript 1.8.0
(function() {
  module.exports = {
    reTagAttr: /(\w+)=['"](.*?)['"](?:[ \t]|$)(.*)$/,
    reGulp: /(\w+):?(.*?)(?:;|$)(.*)$/,
    parse: function(regex, str) {
      var key, map, match, val, _ref;
      map = {};
      while (match = regex.exec(str)) {
        _ref = match.slice(1, 4), key = _ref[0], val = _ref[1], str = _ref[2];
        map[key] = val;
      }
      return map;
    }
  };

}).call(this);

//# sourceMappingURL=parseAttrs.js.map