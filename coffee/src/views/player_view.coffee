goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'


# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView

  className: 'player-view'

  initialize: =>
    super()

    @eventhub.on 'show:edit', => @content @editView()
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

  editView: =>
    @_editView ?= new acorn.player.EditView
      eventhub: @eventhub
      model:
        # clone models to edit safely.
        acornModel: @model.acornModel.clone()
        shellModel: @model.shellModel.clone()
    @_editView
