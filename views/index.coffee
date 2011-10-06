# Topbar
div '.topbar', ->
  div '.topbar-inner', ->
    div '.container', ->
      a '.brand', -> 'jotihunt.mycel.nl'
      ul '.nav', ->
        li -> a href: '/',-> '2011'
        li -> a href: '/?#2010',-> '2010'
      ul '.pull-right.nav.secondary-nav', ->
        li '.dropdown', ->
          a '.dropdown-toggle', -> 'Gast'
          ul '.dropdown-menu', ->
            li -> a 'Verander je naam'
# Rest van de site
div '.hintform.popover.left', style: 'z-index: 10001', ->
  div '.arrow', ->
  div '.inner', ->
    h3 '.title', -> 'Alpha - 14:00'
    form '.form-stacked.content', style: 'padding:0;margin:0', method: 'post', action: '/hints', ->
      div '.modal-body', ->
        coffeescript ->
          $ ->
            $('.hintform .cancel').bind 'click', (event) ->
              event.preventDefault()
              $('.hintform').hide()
            $('.hinttype').bind 'change', (event) ->
              none = $(this).val() == 'none'
              $('.coordinate').toggleClass 'hidden', $(this).val() == 'address' or none
              $('.address').toggleClass 'hidden', $(this).val() != 'address' or none
            $('.btn').bind 'click', ->
              form = $ '.hintform'
              form.show()
              form.position
                of: $ this
                my: 'left center'
                at: 'right center'
                offset: ''
                collision: 'flip flip'
              form.toggleClass 'left', form.hasClass('ui-flipped-left')
              form.toggleClass 'right', !form.hasClass('ui-flipped-left')
              i = parseInt $(this).data('time') - 1
              $('.hintform .title').text("#{$(this).data('group')} - #{(9+i) % 24}:00")
              #alert 'test'
        label 'Soort:'
        select '.hinttype', ->
          option value: 'rdc', -> 'Rijksdriehoekscoördinaten'
          option value: 'latlng', -> 'Geografische coördinaten'
          option value: 'address', -> 'Adres'
          option value: 'none', -> 'Geen'
        div '.coordinate', ->
          label 'Coördinaat:'
          input '.mini', maxlength: 6

          span ','
          input '.mini', maxlength: 6
        div '.address.hidden', ->
          label 'Adres:'
          input type: 'text'


      div '.modal-footer', ->
        button '.btn.primary', -> 'Toevoegen'
        button '.btn.cancel', -> 'Annuleren'

div '.container.page', ->
  div '.row', ->
    div '#mapholder.span9', -> div('.content', -> div '#map', ->)
    div '#tableholder.span11', ->
      style '.width { width: 97px; } .full-width { width: 45px }'
      table '.scroll.scroll-head', ->
        thead ->
          tr ->
            th '.width.red',-> 'Alpha'
            th '.width.green',-> 'Bravo'
            th '.width.blueDark',-> 'Charlie'
            th '.width.blue',-> 'Delta'
            th '.width.purple',-> 'Echo'
            th '.width.yellow',-> 'Foxtrot'
            th '.full-width', -> 'Tijd:'


        btn = (group, i) ->
          button '.btn', 'data-group': group, 'data-time': 1+i, -> 'Invullen'
        tbody style: 'height: 569px', ->
          for i in [0..29]
            tr style: 'height: 48px', ->
              td '.width', -> btn 'Alpha', i
              td '.width', -> btn 'Bravo', i
              td '.width', -> btn 'Charlie', i
              td '.width', -> btn 'Delta', i
              td '.width', -> btn 'Echo', i
              td '.width', -> btn 'Foxtrot', i
              td '.full-width', -> "#{(9+i) % 24}:00" # HACK
