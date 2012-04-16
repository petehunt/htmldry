define ['jquery'], ($) ->
  SELF_CLOSE =
    br: true
    hr: true

  htmlescape = (s) ->
    return s.raw  if s._is_xss
    s = s.toString()
    s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace />/g, "&gt;"

  is_not_attrs = (a) ->
    typeof (a) is "string" or a._is_not_attrs

  render = (v) ->
    unless v
      ""
    else if v._is_tag
      tag2str v
    else if v.apply
      render v.apply(null)
    else if $.isArray(v)
      $(v).map((i, e) ->
        render e
      ).toArray().join ""
    else
      htmlescape v

  tag2str = (tag) ->
    attrs = ""
    for own k of tag.attrs
      attrs += " " + k + "=" + JSON.stringify(tag.attrs[k])
    children = render(tag.children)
    return "<" + tag.name + attrs + " />"  if not children.length and SELF_CLOSE[tag.name]
    "<" + tag.name + attrs + ">" + children + "</" + tag.name + ">"

  tag = (name, attrs, args...) ->
    if is_not_attrs(attrs)
      args.unshift attrs
      attrs = null
    _is_tag: true
    _is_not_attrs: true
    name: name
    attrs: attrs
    children: args
    toString: ->
      tag2str this

  XSS = (s) ->
    _is_xss: true
    raw: s
    _is_not_attrs: true

  generic_tag = (selector, attrs, args...) ->
    if attrs? and is_not_attrs(attrs)
      args.unshift attrs
      attrs = {}
    if not attrs?
      attrs = {}

    attrlist = selector.match(/\[(.*?=.*?)+\]/g)
    if attrlist?
      selector = selector.replace(attrlist[0], "")
      attrlist = attrlist[0].substring(1)
      attrlist = attrlist.match(/.*?=.*?[\],]/g)

      for i in [0..attrlist.length-1]
        expr = attrlist[i].substring(0, attrlist[i].length - 1)
        key = expr.match(/^([^=]+)/g)[0]
        value = expr.substring(key.length + 1)
        attrs[key] = JSON.parse(value)

    tagname = selector.match(/^[A-Za-z0-9\-\:]*/)[0]
    id = selector.match(/#[^\s#\.^\[]+/g)
    cls = selector.match(/\.[^\s#\.^\[]+/g)
    cls = cls.join(" ").replace(/\./g, "")  if cls

    attrs.id = id  if id
    attrs["class"] = cls  if cls

    args.unshift attrs
    args.unshift tagname

    tag.apply null, args

  $.T = generic_tag
  $.T.XSS = XSS

  $.T