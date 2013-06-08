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


  defaults: =>
    show: 'splash'
    autoplay: true


  initialize: =>
    @$el ?= $('<div>').addClass('acorn-player')
    @el = @$el[0]

    @options = _.defaults @options, @defaults()

    @model = @options.model ? @options.acornModel
    if !@model and @options.data
      @model ?= acorn @options.data

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'

    # Alias @model to @acornModel for backwards compatibility.
    # NOTE: this is deprecated, and will go away. use @model instead!
    @acornModel = @model

    @eventhub = @

    @options.editable = @options.editable or @acornModel.isNew()
    @options.autoplay = !_.contains ['false', '0'], @options.autoplay

    @view = new acorn.player.PlayerView
      model: @acornModel,
      eventhub: @eventhub
      editable: @options.editable
      autoplay: @options.autoplay


  destroy: =>
    @view.destroy()
    @$el?.remove()


  editable: (editable) =>
    if editable?
      editable = editable or @acornModel.isNew()
      @view.editable editable
    @view.editable()


  render: =>
    @showView()
    @$el.append @view.render().el
    @


  # trigger event to show correct view based on options and model
  showView: =>
    if @options.show.slice(0,6) == 'editor'
      options = {}

      # editor-single shows a simplified, single-shell editor
      if /single/.test @options.show
        options.singleShellEditor = true

      # editor-minimize shows a minimized editor
      if /minimize/.test @options.show
        options.minimize = true

      @eventhub.trigger 'show:editor', options

    else if @options.show.slice(0,7) == 'content'

      # content-<n> shows content after showing splash page for n milliseconds
      rest = @options.show.slice 8
      delay = parseInt rest

      if rest == 'paused'
        @view.options.autoplay = false
        @eventhub.trigger 'show:content'
      else if delay > 0
        @eventhub.trigger 'show:splash'
        setTimeout (=> @eventhub.trigger 'show:content'), delay
      else
        @eventhub.trigger 'show:content'

    else
      @eventhub.trigger 'show:splash'


  appendTo: (sel) =>
    @render()
    @$el.appendTo $(sel)
