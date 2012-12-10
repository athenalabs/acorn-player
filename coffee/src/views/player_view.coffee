goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'

# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView

  className: 'acorn-player'

  intitialize: =>
    @player = @options.player

    @eventhub.on 'show:edit', @onShow
    @eventhub.on 'show:splash', @onShow
    @eventhub.on 'show:content', @onShow

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

  onShow: (eventName) =>
    switch eventName
      when 'show:edit' then @content @editView()
      when 'show:splash' then @content @splashView()
      when 'show:content' then @content @contentView()
