# Zang is a library for managing simple HTML5 pushstate based applications
# based heavily on jquery.pjax.js and Backbone.Router

class Zang
  hasPushState =
    window.history and
    window.history.pushState and
    window.history.replaceState and
    not navigator.userAgent.match(/((iPod|iPhone|iPad).+\bOS\s+[1-4]|WebApps\/.+CFNetwork)/)

  leadingSlash = /^\//
  trailingSlash = /\/$/

  # create a new router. root is optional, but if provided should
  # be a path beginning with / and without a trailing slash
  constructor: (routes, @root='/') ->
    @root = @root.replace(trailingSlash, '') if @root isnt '/'
    @routes = []
    for route, opts of routes
      @register route, opts


  # Registers a route.
  # Note that leading slashes are removed from the regex
  register: (route, options) ->
    route_regex = @_routeToRegex(route)

    callback = (path) =>
      # path = @_targetPath(path)
      options.callback && options.callback(path)

    @routes.push [route, route_regex, callback]
    return

  # Initializes the router and binds the various events
  start: ->
    return false if @initialized or not hasPushState

    @initialized = true
    @initialUrl = @_getPath(window.location)
    @loadedPath = @initialUrl

    # http://stackoverflow.com/questions/6421769/popstate-on-pages-load-in-chrome
    @initialPop = 'state' in window.history

    @_handleClicks()
    @_handlePops()

    return true


  # navigates to the path and (if given) executes callback on success
  goto: (path) ->
    if @_matchState(path)
      window.history.pushState {}, document.title, @_targetPath(path)
      return true
    return false


  _handlePops: ->
    $(window).bind 'popstate', (event) =>
      return if @initialPop and @loadedPath is @initialURL
      @initialPop = false

      path = @_getPath(window.location)
      @_matchState(path)


  # Handles link-based navigation
  # turns regular links into super links!
  _handleClicks: ->
    $('html').on 'click', 'a[href]', (e) =>

      # Middle click, cmd click, and ctrl click
      return if e.which > 1 or e.metaKey
      if @goto @_getPath(e.target)
        e.preventDefault()


  # Given a path (as processed by _getPath), search
  # for a match among the routes and execute the registered
  # callback if a match is found
  _matchState: (path) ->
    # already loaded?
    if path is @loadedPath
      return false

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
    if path.length > 0 and path[0] is '?'
    then "#{@root}#{path}"
    else "#{@root}/#{path}"


  # Gets the path of interest from a location or target object
  # (note, without root or leading slash)
  _getPath: (loc) ->
    path = decodeURIComponent(loc.pathname)
    search = loc.search
    path += search if search
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
                 .replace(splatParam, '(.*?)')
                 .replace(leadingSlash);
    new RegExp('^' + route + '$');
