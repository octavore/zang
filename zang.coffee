# Zang is a library for managing simple HTML5 pushstate based applications
# based heavily on jquery.pjax.js and Backbone.Router

class Zang
  hasPushState =
    window.history and
    window.history.pushState and
    window.history.replaceState and
    not navigator.userAgent.match(/((iPod|iPhone|iPad).+\bOS\s+[1-4]|WebApps\/.+CFNetwork)/)


  constructor: (routes, @root='/') ->
    @routes = []
    for route, opts of routes
      @register route, opts


  # Registers a route
  register: (route, options) =>
    route_regex = @_routeToRegex(route)

    callback = (path) =>
      path = @_targetPath(path)
      options.callback && options.callback(path)

    @routes.push [route, route_regex, callback]
    return

  # Initializes the router and binds the various events
  start: =>
    return false if @initialized or not hasPushState

    @initialized = true
    @initialUrl = @_getPath(window.location)
    @loadedPath = @initialUrl

    @_handleClicks()
    @_handlePops()

    return true


  # navigates to the path and (if given) executes callback on success
  goto: (path, callback) =>
    if path isnt @loadedPath
      if @_matchState(path)
        window.history.pushState {}, document.title, @_targetPath(path)
        callback() if callback?
        return true
    return false


  _handlePops: =>
    $(window).bind 'popstate', (event) =>
       badPop = not @popped or @loadedPath is @initialURL
       @popped = true
       return if badPop
       @_checkUrl()


  # Handles link-based navigation
  # turns regular links into super links!
  _handleClicks: =>
    $('html').on 'click', 'a', (e) =>

      # Middle click, cmd click, and ctrl click
      return if e.which > 1 or e.metaKey

      @goto @_getPath(e.target), ->
         e.preventDefault()


  # checks the current url against routes
  _checkUrl: =>
    path = @_getPath(window.location)
    @_matchState(path) if path isnt @loadedPath


  # Given a path (as processed by _getPath), search
  # for a match among the routes and execute
  # callback if a match is found
  _matchState: (path) =>
    matched = false

    for route_array in @routes
      [route, route_regex, route_callback] = route_array
      if route_regex.test(path)
        @loadedPath = path
        matched = true
        route_callback(path)
        break

    return matched

  # Return the full path, inclusive of root
  _targetPath: (path) ->
    @root + path


  # Gets the path of interest from a location or target object
  # (note, without root or leading slash)
  leadingSlash = /^\//;
  _getPath: (loc) ->
    path = decodeURIComponent(loc.pathname)
    search = loc.search;
    path += search if search;
    path = path.substr(@root.length) if not path.indexOf(@root)
    return path.replace(leadingSlash, '')


  # Convert route to regular expression
  # Note: removes leading slash
  # Extracted from Backbone.js
  namedParam    = /:\w+/g
  splatParam    = /\*\w+/g
  escapeRegExp  = /[-[\]{}()+?.,\\^$|#\s]/g
  _routeToRegex: (route) ->
    route = route.replace(escapeRegExp, '\\$&')
                 .replace(namedParam, '([^\/]+)')
                 .replace(splatParam, '(.*?)');
    new RegExp('^' + route + '$');
