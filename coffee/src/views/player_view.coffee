goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditorView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'


# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView

  className: 'player-view row-fluid'

  initialize: =>
    super()

    @eventhub.on 'show:edit', => @content @editorView()
    @eventhub.on 'show:splash', => @content @splashView()
    @eventhub.on 'show:content', => @content @contentView()

    @content @splashView()

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
