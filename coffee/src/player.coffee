goog.provide 'acorn.player.Player'

goog.require 'acorn.player.PlayerView'

# The main class, represents the entire player object.
# Also serves as the eventhub.
class acorn.player.Player

  # mixin Backbone.Events (not a class)
  _.extend @prototype, Backbone.Events

  constructor: (@options) ->
    @initialize()

  initialize: =>
    @acornModel = @options.acornModel # TODO initialize from id or data
    @shellModel = acorn.shellWithAcorn @acornModel

    @view = new acorn.player.PlayerView
      model: {acornModel: @acornModel, shellModel: @shellModel}
      eventhub: @

    @registerShellModule (shellModule) =>
      # static shell registry; created on first call
      @shellRegistry ?= {}

      # validate that shellModule contains required String properties
      required_properties = [ 'id', 'title', 'description' ]
      _.each required_properties, (property) ->
        unless shellModule[property]?
          MissingParameterError "shell registration", property

        unless _.isString shellModule[property]
          TypeError property, 'str'

      # validate that shellModule contains a Model object
      unless shellModule.Model?
        MissingParameterError "shell registration", "Model"

      # populate shellModule with default properties from Shell
      _.each acorn.shells.Shell, (value, key) ->
        unless shellModule[key]?
          shellModule[key] = _.clone value

      # validate shellModule's Model and View properties
      class_properties = [ 'Model', 'ContentView', 'SummaryView', 'EditView' ]
      _.each view_properties, (property) ->
        unless _.isFunction shellModule[property]
          TypeError property, 'class'

      # set the `shell` property of each class within shellModule to point
      # back to the shellModule namespace
      _.each class_properties, (property) ->
        shellModule[property].shell = shellModule

      # register shell
      @shellRegistry[shellModule.id] = shellModule
