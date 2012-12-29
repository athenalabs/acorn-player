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

    unless @options.acornModel instanceof acorn.Model
      TypeError @options.acornModel, 'acorn.Model'

    @acornModel = @options.acornModel # TODO initialize from id or data
    @shellModel = acorn.shellWithAcorn @acornModel
    @eventhub = @

    @view = new acorn.player.PlayerView
      model:
        shellid: 'acorn.Shell',
        acornModel: @acornModel,
        shellModel: @shellModel
      eventhub: @eventhub

    if @acornModel.isNew()
      @eventhub.trigger 'show:edit'
    else
      @eventhub.trigger 'show:splash'

  appendTo: (sel) =>
    @$el ?= $('<div>').addClass('acorn-player')
    @$el.append @view.render().el
    @$el.appendTo $(sel)
