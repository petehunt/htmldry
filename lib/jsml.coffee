define ['jquery'], ($) ->

  jsml_attr = (tag, attrs, include_attrs = false) ->
    classes = ''
    classes = '.' + attrs['class'].value.split(' ').join('.')  if attrs['class']
    id = ''
    id = '#' + attrs['id'].value  if attrs['id']
    attrlist = []
    if attrs.length > 0 and include_attrs
      for i in [0..attrs.length-1]
        item = attrs.item(i)

        if item.name == 'class' or item.name == 'id'
          continue
        attrlist.push item.name + '=' + JSON.stringify(item.value)
      if attrlist.length == 0
        attrlist = ''
      else
        attrlist = '[' + attrlist.join(',') + ']'
    if tag == 'div' and (id.length > 0 or classes.length > 0)
      tag = ''
    return tag + id + classes + attrlist

  domattr2dict = (attrs) ->
    if attrs.length == 0
      return {}
    ret = {}
    for i in [0..attrs.length - 1]
      item = attrs.item(i)
      ret[item.name] = item.value
    ret

  count_dict = (d) ->
    count = 0
    for own k of d
      count += 1
    count

  html2jsml = (node, indent, include_attrs = false) ->
    if not indent?
      indent = ''

    switch node.nodeType
      when Node.ELEMENT_NODE
        open = indent + "o " + JSON.stringify(jsml_attr(node.tagName.toLowerCase(), node.attributes, include_attrs))
        if not include_attrs
          attrs = domattr2dict(node.attributes)
          delete attrs['id']
          delete attrs['class']
          count = count_dict(attrs)
          if count > 0
            open += ', ' + JSON.stringify(attrs)

        if node.childNodes.length > 0
          # optimization for single text nodes
          if node.childNodes.length == 1 and node.childNodes[0].nodeType == Node.TEXT_NODE
            child_content = html2jsml(node.childNodes[0], '', include_attrs)
            open += ', ' + child_content  if child_content?
            return open
          indent += '  '
          first = true
          for child in node.childNodes
            child_content = html2jsml(child, indent, include_attrs)
            if child_content?
              if first
                first = false
                open += ','
              open += '\n' + child_content
        open
      when Node.TEXT_NODE
        if node.textContent.trim().length > 0
          indent + JSON.stringify(node.textContent.trim())

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
      @render()
    render: ->
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
    tagname = 'div'  if not tagname

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
  $.T.html2jsml = html2jsml

  $.T