goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditorView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'
goog.require 'acorn.player.ControlsView'
goog.require 'acorn.player.OverlayView'
goog.require 'acorn.player.SourcesView'


# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView

  className: "#{@::className} player-view row-fluid"

  initialize: =>
    super

    @eventhub.on 'show:editor', => @content @editorView()
    @eventhub.on 'show:splash', => @content @splashView()
    @eventhub.on 'show:content', => @content @contentView()

    @eventhub.on 'Editor:Saved', @onSave
    @eventhub.on 'Editor:Cancel', =>
      @_editorView?.destroy()
      @_editorView = undefined
      @content @contentView()

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
    @_editorView ?= new acorn.player.EditorView
      eventhub: @eventhub
      model:
        # clone models to edit safely.
        acornModel: @model.acornModel.clone()
        shellModel: @model.shellModel.clone()
    @_editorView


  onSave: =>
    @model.acornModel.set @_editorView.model.acornModel.attributes
    @model.shellModel.set @model.acornModel.shellData()

    # clear previous contentView to force reload, then show
    @_contentView?.destroy()
    @_contentView = undefined
    @content @contentView()

    # clear editorView
    @_editorView?.destroy()
    @_editorView = undefined
