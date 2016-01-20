do ->

  app_name = "auto_js_rails"
  version_number = "1.0.0"

  ###
  # auto_js configuration
  # The following variables set up the JS Organization environment
  # Will be available at global scope i.e. accessible at window['my_rails_app']
  ###
  window['auto_js_rails'] = {}
  window['auto_js_rails'].version = version_number
  window['auto_js_rails'].app_name = app_name

  ###
  # The main object, at global scope, which contains all the JS code for the rails app.
  ###
  window[ app_name ] = {}
  self = window[app_name]

  ##
  # window.app_name.scopes is a wrapper to keep all the page/controller specific code separated
  # from any utility functions or app variables
  ##
  self.scopes = {}

  ##
  # window.app_name.utils is a wrapper for all the JS code that may be needed in multiple
  # controllers / view combinations, such as form validators
  ##
  self.utils = {}

  ##
  # window.app_name.vars is a wrapper for all the app-wide variables that may be needed
  ##
  self.vars = {}

  ##
  # window.app_name.initializers is a wrapper for all initializers
  ##
  self.initializers = {}


  ###
  # Convenience method for setting an alias to access auto_js.
  # By default, the js code is accessible at window['auto_js_rails']
  # By specifying an alias, the js code is acessible at 'alias'
  ###
  self.set_alias = (name) ->

    if( window[ name ] )
      console.error("Error: '" + name + "' is already used at the global scope and can't be used as an alias for auto_js_rails.")

    else
      window[ name ] = window['auto_js_rails']

    return

  ###
  # Calls the appropriate block of JS for the provided controller and action.
  # The second parameter is optional, with a default of "_init".
  # If the provided controller and action don't resolve to a function, _exec silently returns
  ###
  self.scopes._exec = (controller, action) ->

    action = if action == undefined then 'init' else action

    valid_call = controller != '' and self.scopes[controller] and typeof self.scopes[controller][action] == 'function'

    if valid_call
      self.scopes[controller][action]()

    return

  ###
  # Runs the common js code required for the main app
  # Also calls _page_init() as, if _app_init() runs this is the first page load
  ###
  self.scopes._app_init = ->

    if ! self.vars._app_initialized

      self.scopes._exec '_application'

      self.vars._app_initialized = true

      self.scopes._page_init()

    return


  ###
  # Runs the common js code required for the current page, which includes controller init
  # as well as view specific code
  ###
  self.scopes._page_init = ->

    if self.vars._page_initialized
      return

    controller = document.body.getAttribute('data-controller')

    while (n = controller.indexOf("/")) != -1
      controller = controller.replace /\//, ""
      controller = controller.substr(0,n) + controller.charAt(n).toUpperCase() + controller.substr(n+1)

    action = document.body.getAttribute('data-action')

    self.scopes._exec controller
    self.scopes._exec controller, action

    self.vars._page_initialized = true

    return


  ###
  # Keeps track of whether or not we need to re-run the page initializer (for turbolinks)
  ###
  self.vars._app_initialized = false
  self.vars._page_initialized = false


  ###
  # If this is running, a full context reload was executed. The app needs reinitialized.
  # This doesn't get fired if turbolinks is handling the navigation transition
  ###
  $(document).ready self.scopes._app_init


  document.addEventListener 'page:before-unload', ->
    self.vars._page_initialized = false

  ###
  # document.ready doesn't get fired on turbolinks load. Bind an event to handle the
  # ajax page loading events triggered by turbolinks
  ###
  document.addEventListener 'page:change', ->

    self.scopes._page_init()

    return

  return
