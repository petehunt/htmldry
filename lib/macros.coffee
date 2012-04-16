define ['jquery'], ($) ->
  MAX_ROUNDS = 1000

  single_round = (macros, context) ->
    count = 0
    for own name of macros
      matches = $("*[data-macro='" + name + "']", context)
      count += matches.size()
      matches.replaceWith macros[name]
      # TODO: below may be incorrect sometimes
      throw "Error: macro " + name + " did not remove all existing elements"  if matches.size() > 0 and matches.html() is $("*[data-macro='" + name + "']", context).html()
    count

  process = (macros, context) ->
    count = 1
    rounds = 0
    while count > 0 and rounds < MAX_ROUNDS
      count = single_round(macros, context)
      rounds += 1
    throw "Error: hit MAX_ROUNDS, you may have a bug in your macros (or they may be slow). Did you forget to remove data-macro?"  if rounds >= MAX_ROUNDS

  MACROS = {}

  $.fn.macros = ->
    process MACROS, this

  $.register_macro = (name, fn) ->
    MACROS[name] = fn

  macros: => $(document).macros()
  register_single: $.register_macro
  register: (module) ->
    for own key of module
      @register_single key, module[key]