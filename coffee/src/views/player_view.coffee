goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'


# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView

  className: 'player-view'

  initialize: =>
    super()
    @player = @options.player

    @eventhub.on 'show:edit', => @content @editView()
    @eventhub.on 'show:splash', => @content @splashView()
    @eventhub.on 'show:content', => @content @contentView()

  # retrieves (and may initialize and render) subviews
  subview: (name, cls, options) =>
    options ?= {}
    key = "_#{name}"
    if not @[key]
      @[key] = new cls _.extend {eventhub: @, model: @model}, options
      @[key].render()
    @[key]

  contentView: (opts) => @subview 'contentView', player.ContentView, opts
  splashView: (opts) => @subview 'splashView', player.SplashView, opts
  editView: (opts) => @subview 'editView', player.EditView, opts
