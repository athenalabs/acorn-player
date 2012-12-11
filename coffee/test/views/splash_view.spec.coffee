goog.provide 'acorn.specs.player.SplashView'

goog.require 'acorn.player.SplashView'

describe 'acorn.player.SplashView', ->
  SplashView = acorn.player.SplashView

  it 'should be part of acorn.player', ->
    expect(acorn.player.SplashView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives SplashView, athena.lib.View).toBe true


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    model = new Backbone.Model
      thumbnail: '/static/img/acorn.png'
      type: 'multimedia'

    view = new SplashView model: model
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el
