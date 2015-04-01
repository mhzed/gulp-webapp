
module.exports =

  reTagAttr: /(\w+)=['"](.*?)['"](?:[ \t]|$)(.*)$/
  reGulp : /(\w+):?(.*?)(?:;|$)(.*)$/
  parse : (regex, str)->
    map = {}
    while match = regex.exec(str)
      [key,val,str]=match[1..3]
      map[key] = val
    map
