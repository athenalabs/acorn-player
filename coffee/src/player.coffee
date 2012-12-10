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
    @acorn = @options.acorn #todo initialize from id or data
    @shell = acorn.shellWithAcorn @acorn

    @view = new acorn.player.PlayerView
      model: @acorn
      player: @
      eventhub: @
