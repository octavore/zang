var slideaway, stack, zangRouter;

if (!zangRouter) {
  stack = [window.location.pathname];
  slideaway = function(path) {
    var fromRight;
    if (stack.indexOf(path) !== -1) {
      stack = stack.slice(0, stack.indexOf(path));
      fromRight = true;
    }
    return $.get(path, function(data) {
      var next, original;
      stack.push(path);
      data = $('<html>').html(data).find('#zang_target').html();
      original = $('.slide_box');
      next = $('<div>', {
        "class": 'slide_box'
      }).html(data);
      if (fromRight != null) {
        next.css({
          marginLeft: -580
        });
        original.before(next);
        return next.animate({
          marginLeft: 0
        }, function() {
          return original.remove();
        });
      } else {
        original.after(next);
        return original.animate({
          marginLeft: -580
        }, function() {
          return original.remove();
        });
      }
    });
  };
  zangRouter = new Zang({
    '': {
      callback: slideaway
    },
    'elephant': {
      callback: slideaway
    }
  });
  zangRouter.start();
}
