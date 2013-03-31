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


  defaults: => {}


  initialize: =>
    @$el ?= $('<div>').addClass('acorn-player')
    @el = @$el[0]

    @options = _.defaults @options, @defaults()

    @model = @options.model ? @options.acornModel
    # TODO initialize from id or data

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'

    # Alias @model to @acornModel for backwards compatibility.
    # NOTE: this is deprecated, and will go away. use @model instead!
    @acornModel = @model

    @eventhub = @

    @options.editable = @options.editable or @acornModel.isNew()

    @view = new acorn.player.PlayerView
      model: @acornModel,
      eventhub: @eventhub
      editable: @options.editable

    if @acornModel.isNew()
      @eventhub.trigger 'show:editor'
    else
      @eventhub.trigger 'show:splash'


  destroy: =>
    @view.destroy()
    @$el?.remove()


  editable: (editable) =>
    if editable?
      editable = editable or @acornModel.isNew()
      @view.editable editable
    @view.editable()


  render: =>
    @$el.append @view.render().el
    @


  appendTo: (sel) =>
    @render()
    @$el.appendTo $(sel)
