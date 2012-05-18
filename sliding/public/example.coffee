if not zangRouter
  stack = [window.location.pathname]
  slideaway = (path) ->

    if stack.indexOf(path) isnt -1
      stack = stack.slice(0,stack.indexOf(path))
      fromRight = true
      
    $.get path, (data) ->
      stack.push path
      data = $('<html>').html(data).find('#zang_target').html()
      original = $('.slide_box')
      next = $('<div>', class: 'slide_box').html(data)
      if fromRight?
        next.css marginLeft: -580
        original.before(next)
        next.animate marginLeft: 0, -> 
          original.remove()
      else
        original.after(next)
        original.animate marginLeft: -580, -> 
          original.remove()
  
  zangRouter = new Zang
    '':
      callback: slideaway
  
    'elephant':
      callback: slideaway
        
  zangRouter.start();
