goog.provide 'acorn.player.Player'

goog.require 'acorn.player.PlayerView'
goog.require 'acorn.shells.Shell'

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
    @eventhub = @

    @view = new acorn.player.PlayerView
      model:
        shellid: 'acorn.Shell',
        acornModel: @acornModel,
        shellModel: @shellModel
      eventhub: @eventhub

    @eventhub.trigger 'show:splash'
