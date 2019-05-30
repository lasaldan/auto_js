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
  document.addEventListener "DOMContentLoaded", ->
    console.log("dom")
    self.scopes._app_init()
    self.prepare_modal_observer()

  ###
  # This sets a flag marking a page as requiring initialization
  # This doesn't get fired if history navigation occurs, thus the page remains initialized
  ###
  document.addEventListener 'turbolinks:before-visit', ->
    console.log("before")
    self.vars._page_initialized = false

  ###
  # DOMContentLoaded doesn't get fired on turbolinks load. Bind an event to handle the
  # ajax page loading events and history events triggered by turbolinks
  ###
  document.addEventListener 'turbolinks:load', ->
    console.log('load')
    self.scopes._page_init()

  ###
  # Set up modal observers for initializing remote loaded content
  ###
  self.prepare_modal_observer = ->
    modal_initializer = (mutations, observer) ->
      console.log(mutations)
      for mutation in mutations
        if mutation.addedNodes.length && mutation.addedNodes[0].classList.contains("modal")
          console.log("initing modal")
          controller = document.body.getAttribute('data-controller')
          self.scopes._exec '_application', '_modal'
          self.scopes._exec controller, 'modal'
          if modal_method = mutation.addedNodes[0].dataset.init_method
            self.scopes._exec controller, modal_method

    modal_observer = new MutationObserver modal_initializer
    modal_observer.observe document.body,
      childList: true

  ###
  # Return nothing
  ###
  return
