define ['jquery', 'cs!lib/macros', 'cs!lib/jsml'], ($, macros, T) ->
  macros.register
    hello_world: ->
      name = $(this).data('name')
      T('div.hello-world',
        'Hello <g>, ',
        T('a[href="http://www.google.com/"]', name)
        '!').toString()

  $(document).ready =>
    macros.macros()