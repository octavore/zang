zangRouter = new Zang
  # go to root
  '':
    callback: (path) ->
      $.get path, (data) ->
        html = $('<html>').html(data)
        $('#zang_target').html(html.find('#zang_target').html())
  
  # grab a fragment
  'elephant':
    callback: (path) ->
      $.get path, (data) ->
        html = $('<html>').html(data)
        $('#zang_target').html(html.find('#elephant').html())
        
zangRouter.start();