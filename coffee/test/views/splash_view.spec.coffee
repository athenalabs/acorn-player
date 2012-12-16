goog.provide 'acorn.specs.player.SplashView'

goog.require 'acorn.player.SplashView'

describe 'acorn.player.SplashView', ->
  SplashView = acorn.player.SplashView

  model = new acorn.Model
    thumbnail: acorn.config.img.acorn
    type: 'image'

  options = model: model


  it 'should be part of acorn.player', ->
    expect(SplashView).toBeDefined()

  describe 'model verification', ->

    it 'should fail to construct if model was not passed in', ->
      expect(-> new SplashView model: undefined).toThrow()

    it 'should fail to construct if model type is incorrect', ->
      expect(-> new SplashView model: {bad: value}).toThrow()
      expect(-> new SplashView model: new Backbone.Model).toThrow()

    it 'should succeed to construct if model type is correct', ->
      expect(model instanceof acorn.Model).toBe true
      expect(-> new SplashView model: model).not.toThrow()

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
