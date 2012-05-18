var Zang,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Zang = (function() {
  var escapeRegExp, hasPushState, leadingSlash, namedParam, splatParam;

  hasPushState = window.history && window.history.pushState && window.history.replaceState && !navigator.userAgent.match(/((iPod|iPhone|iPad).+\bOS\s+[1-4]|WebApps\/.+CFNetwork)/);

  function Zang(routes, root) {
    var opts, route;
    this.root = root != null ? root : '/';
    this._matchState = __bind(this._matchState, this);
    this._checkUrl = __bind(this._checkUrl, this);
    this._handleClicks = __bind(this._handleClicks, this);
    this._handlePops = __bind(this._handlePops, this);
    this.start = __bind(this.start, this);
    this.register = __bind(this.register, this);
    this.routes = [];
    for (route in routes) {
      opts = routes[route];
      this.register(route, opts);
    }
  }

  Zang.prototype.register = function(route, options) {
    var callback, route_regex,
      _this = this;
    route_regex = this._routeToRegex(route);
    callback = function(path) {
      path = _this._targetPath(path);
      return options.callback && options.callback(path);
    };
    this.routes.push([route, route_regex, callback]);
  };

  Zang.prototype.start = function() {
    if (this.initialized || !hasPushState) return false;
    this.initialized = true;
    this.initialUrl = this._getPath(window.location);
    this.loadedPath = this.initialUrl;
    this._handleClicks();
    this._handlePops();
    return true;
  };

  Zang.prototype._handlePops = function() {
    var _this = this;
    return $(window).bind('popstate', function(event) {
      var badPop;
      badPop = !_this.popped || _this.loadedPath === _this.initialURL;
      _this.popped = true;
      if (badPop) return;
      return _this._checkUrl();
    });
  };

  Zang.prototype._handleClicks = function() {
    var _this = this;
    return $('html').on('click', 'a', function(e) {
      var path;
      if (e.which > 1 || e.metaKey) return;
      path = _this._getPath(e.target);
      if (path !== _this.loadedPath) {
        if (_this._matchState(path)) {
          window.history.pushState({}, document.title, _this._targetPath(path));
          return e.preventDefault();
        }
      }
    });
  };

  Zang.prototype._checkUrl = function() {
    var path;
    path = this._getPath(window.location);
    if (path !== this.loadedPath) return this._matchState(path);
  };

  Zang.prototype._matchState = function(path) {
    var matched, route, route_array, route_callback, route_regex, _i, _len, _ref;
    matched = false;
    _ref = this.routes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      route_array = _ref[_i];
      route = route_array[0], route_regex = route_array[1], route_callback = route_array[2];
      if (route_regex.test(path)) {
        this.loadedPath = path;
        matched = true;
        route_callback(path);
        break;
      }
    }
    return matched;
  };

  Zang.prototype._targetPath = function(path) {
    return this.root + path;
  };

  leadingSlash = /^\//;

  Zang.prototype._getPath = function(loc) {
    var path, search;
    path = decodeURIComponent(loc.pathname);
    search = loc.search;
    if (search) path += search;
    if (!path.indexOf(this.root)) path = path.substr(this.root.length);
    return path.replace(leadingSlash, '');
  };

  namedParam = /:\w+/g;

  splatParam = /\*\w+/g;

  escapeRegExp = /[-[\]{}()+?.,\\^$|#\s]/g;

  Zang.prototype._routeToRegex = function(route) {
    route = route.replace(escapeRegExp, '\\$&').replace(namedParam, '([^\/]+)').replace(splatParam, '(.*?)');
    return new RegExp('^' + route + '$');
  };

  return Zang;

})();
