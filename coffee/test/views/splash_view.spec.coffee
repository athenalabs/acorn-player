goog.provide 'acorn.specs.player.SplashView'

goog.require 'acorn.player.SplashView'

describe 'acorn.player.SplashView', ->
  SplashView = acorn.player.SplashView

  options =
    model: new Backbone.Model
      thumbnail: acorn.config.img.acorn
      type: 'image'


  it 'should be part of acorn.player', ->
    expect(acorn.player.SplashView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView SplashView, athena.lib.View, options

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new SplashView options
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el
