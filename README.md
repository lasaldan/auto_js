# auto_js

auto\_js fills the gap between the default rails management of javascript and a full front-end framework. It allows for automatic execution of code based on controller/view as well as ad-hoc reuse of javascript functions.

auto\_js is compatible with turbolinks, and works with javascript or coffeescript.

## Installation

Add the following to your `gemfile`:

    gem auto_js

then `bundle install`

or install from Rubygems with:

    gem install auto_js

## Setup

Add the following to your `application.js`:

    //= require js_organize

Add the following to the `body` tag on every layout you want to use auto\_js

    data-controller="<%= params[:controller] %>" data-action="<%= params[:action] %>"

## Usage - Scope based Execution

auto\_js stores all your javasript code in an object literal with a single variable exposed at global scope. You can indicate which javascript to execute by placing it in the appropriate location in the object literal.

#### Application-wide Javascript

You can define application-wide code with:

    my_application.scopes._application =
      init: ->
        console.log("Initializing Application")


This will execute `my_application.scopes._application.init()` whenever a full context reload is requested. This is useful for binding events at the document/window level. To avoid multi-binding of events, it will not run on navigation events if turbolinks is enabled. This is the first javascript function to be run with autojs.

#### Controller-wide Javascript

You can define controller-wide code with:

    my_application.scopes.users =
      init: ->
        console.log("Initializing Users Controller")

This will execute on any view rendered by the `Users` controller and will run after the application `init()` and before the view specific javascript.

#### View Specific Javascript

You can define view specific code with:

    my_appliation.scopes.users =
      edit: ->
        console.log("User Edit View")
  
      index: ->
        console.log("User Index View")
        

This will execute the `edit()` function on the User edit page, and the `index()` function on the User index page.

#### All Together

Consider the following example which combines all the previous snippits:

    my_application.scopes =
      _application:
        init: ->
          console.log("Initializing Application")
    
      users:
        init: ->
          console.log("Initializing Users Controller")

        index: ->
          console.log("Users-Index page")

        edit: ->
          console.log("Users-Edit page")


Visiting `/users` would output the following:

    Initializing Application
    Initializing Users Controller
    Users-Index page

For application with large amounts of javascripts, it is recommended to break up the object literal into multiple files. A good idea might be to use the auto-generated files provided by rails scaffold.

## Usage - Utilities

auto\_js comes with an additional object (accessible at `my_application.utils`). Use this for code that needs to be used across unrelated views, such as form validators.

    my_application.utils = 
      fieldHasText: (field) ->
        return !! field.value.length
        

## Usage - Global Variables

auto\_js provides a namespaced object for storing any global variables you may need to use. While globally accessible variables are generally avoided, there are some cases (especially when using turbolinks) in which using globals makes sense.

    my_appliation.vars =
    	windowTimer: null
    	geoLocation: {lat: 0, lon: 0}
