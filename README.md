Zang.js
==============

Zang.js is a simple Javascript framework for working with the HTML5 pushstate API. It is written in CoffeeScript.

Clicks on links that match the defined routes are automatically captured by the framework.

Based heavily on jquery.pjax.js and Backbone.Router. Thanks you guys!

Requires jQuery 1.7+

Example
------
The following snippet, taken from the demo matches the root url and also ```/elephants```.

```javascript
var zangRouter = new Zang({
  '': {
    callback: function(path) {
      return $.get(path, function(data) {
        var html = $('<html>').html(data);
        return $('#zang_target').html(html.find('#zang_target').html());
      });
    }
  },
  'elephant': {
    callback: function(path) {
      return $.get(path, function(data) {
        var html = $('<html>').html(data);
        return $('#zang_target').html(html.find('#elephant').html());
      });
    }
  }
});

zangRouter.start();
```