goog.provide 'acorn.player.Player'

goog.require 'acorn.player.PlayerView'

# The main class, represents the entire player object.
# Also serves as the eventhub.
class acorn.player.Player

  # mixin Backbone.Events (not a class)
  _.extend @, Backbone.Events

  constructor: (@options) ->
    @initialize()

  initialize: =>
    @acornModel = @options.acorn # TODO initialize from id or data
    @shellModel = acorn.shellWithAcorn @acorn

    @view = new acorn.player.PlayerView
      model: {acornModel: @acornModel, shellModel: @shellModel}
      player: @
      eventhub: @
