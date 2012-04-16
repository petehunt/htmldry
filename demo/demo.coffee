define ['jquery', 'cs!lib/macros', 'cs!lib/jsml'], ($, macros, t) ->
  macros.register
    eventBlock: ->
      t '.tEventBlock',
        t 'h6.tTimeHeader', $(this).data('title')
        t.XSS $(this).html()

    event: ->
      score = $(this).data('score')
      num_comments = ''
      if $(this).data('num-comments') > 0
        num_comments = ' (' + $(this).data('num-comments') + ')'
      num_people = $(this).data('num-people')
      if num_people == 1
        num_people = '1 person'
      else
        num_people = num_people + ' people'

      return  t '.tEvent.container',
        t '.row',
          t '.span6',
            t 'div',
              t '.pull-left',
                t.XSS '&#9650'
                t 'br'
                t '.tSubtle.tEventScore', score
                t.XSS '&#9660'
              t 'h1.tEventTitle',
                t 'a[href="#"]', $(this).data('title')
              t 'span.tEventLinks.tSubtle',
                t 'a[href="#"]', 'More info'
                t.XSS ' &middot; '
                t 'a[href="#"]', 'Comments' + num_comments
                t.XSS ' &middot; '
                t 'a[href="#"]', "I'm going"
          t '.span3',
            t 'h5.tSubtle', $(this).data('location')
            t 'h5.tSubtle', $(this).data('timerange')
            t 'h5.tSubtle', num_people + ' are going'
  $(document).ready =>
    macros.macros()