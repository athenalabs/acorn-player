goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditorView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'
goog.require 'acorn.player.OverlayView'
goog.require 'acorn.player.SourcesView'
goog.require 'acorn.player.TimeInputView'
goog.require 'acorn.player.TimeRangeInputView'
goog.require 'acorn.player.CycleButtonView'



# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView


  className: @classNameExtend 'player-view row-fluid'


  initialize: =>
    super

    unless @model.acornModel instanceof acorn.Model
      TypeError @model.acornModel, 'acorn.Model'

    unless @model.shellModel instanceof acorn.shells.Shell.Model
      TypeError @model.shellModel, 'acorn.Model'

    @editable !!@options.editable

    @eventhub.on 'show:editor', =>
      unless @editable() then return
      @content @editorView()
      @$el.attr 'showing', 'editor'

    @eventhub.on 'show:splash', =>
      @content @splashView()
      @$el.attr 'showing', 'splash'

    @eventhub.on 'show:content', =>
      @content @contentView()
      @$el.attr 'showing', 'content'

    @eventhub.on 'Editor:Saved', @onSave
    @eventhub.on 'Editor:Cancel', =>
      unless @editable()
        return
      @_editorView?.destroy()
      @_editorView = undefined
      @content @contentView()

    @eventhub.on 'EditControl:Click', =>
      if @editable()
        @eventhub.trigger 'show:editor'
    @eventhub.on 'AcornControl:Click', => @openAcornWebsite()
    @eventhub.on 'SourcesControl:Click', => @eventhub.trigger 'show:sources'
    @eventhub.on 'FullscreenControl:Click', => @enterFullscreen()


  contentView: =>
    @_contentView ?= new acorn.player.ContentView
      eventhub: @eventhub
      model: @model
    @_contentView


  splashView: =>
    @_splashView ?= new acorn.player.SplashView
      eventhub: @eventhub
      model: @model.acornModel
    @_splashView


  editorView: =>
    unless @editable()
      return

    @_editorView ?= new acorn.player.EditorView
      eventhub: @eventhub
      model: @model.acornModel.clone()
    @_editorView


  editable: (editable) =>
    if editable?
      @_editable = editable

      # adjust editable class
      if @_editable
        @$el.addClass 'editable'
        @$el.removeClass 'uneditable'
      else
        @$el.removeClass 'editable'
        @$el.addClass 'uneditable'

    @_editable


  onSave: =>
    unless @editable()
      return

    @model.acornModel.set @_editorView.model.attributes
    @model.shellModel.set @model.acornModel.shellData()

    # clear previous contentView to force reload, then show
    @_contentView?.destroy()
    @_contentView = undefined
    @content @contentView()

    # clear editorView
    @_editorView?.destroy()
    @_editorView = undefined


  enterFullscreen: =>
    acorn.util.fullscreen @$el.parent()


  openAcornWebsite: =>
