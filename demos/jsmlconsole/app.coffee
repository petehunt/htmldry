define ['jquery', 'cs!lib/macros', 'cs!lib/jsml'], ($, macros, t) ->
  $(document).ready ->
    $('#htmlText').keyup ->
      html = $($(this).val())[0]
      $('#jsmlText').val t.html2jsml(html)

    macros.macros()