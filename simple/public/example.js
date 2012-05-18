(function() {
  var zangRouter;

  zangRouter = new Zang({
    '': {
      callback: function(path) {
        return $.get(path, function(data) {
          var html;
          html = $('<html>').html(data);
          return $('#zang_target').html(html.find('#zang_target').html());
        });
      }
    },
    'elephant': {
      callback: function(path) {
        return $.get(path, function(data) {
          var html;
          html = $('<html>').html(data);
          return $('#zang_target').html(html.find('#elephant').html());
        });
      }
    }
  });

  zangRouter.start();

}).call(this);
