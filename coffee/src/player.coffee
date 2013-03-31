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
    if @acornModel.isNew() or @options.show.slice(0,6) == 'editor'
      # editor-single shows a simplified, single-shell editor
      if @options.show.slice(7) == 'single'
        options = singleShellEditor: true
      @eventhub.trigger 'show:editor', options

    else if @options.show.slice(0,7) == 'content'
      # content-<n> shows content after showing splash page for n milliseconds
      delay = parseInt @options.show.slice 8
      if delay > 0
        @eventhub.trigger 'show:splash'
        setTimeout (=> @eventhub.trigger 'show:content'), delay
      else
        @eventhub.trigger 'show:content'

    else
      @eventhub.trigger 'show:splash'


  appendTo: (sel) =>
    @render()
    @$el.appendTo $(sel)
