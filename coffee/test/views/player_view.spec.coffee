goog.provide 'acorn.specs.player.PlayerView'

goog.require 'acorn.player.PlayerView'

describe 'acorn.player.PlayerView', ->
  PlayerView = acorn.player.PlayerView
  derives = athena.lib.util.derives

  # model for PlayerView contruction
  model =
    shellModel: new Backbone.Model
    acornModel: new Backbone.Model
      acornid: 'thebestacornever'
      thumbnail: acorn.config.img.acorn
      title: 'The Best Title Ever'
      type: 'image'

  # emulate shell, object with a ContentView property
  shell = ContentView: athena.lib.View
  model.shellModel.shell = shell

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(PlayerView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView PlayerView, athena.lib.View, options

  describePlayerSubiew = (name, View) ->

    describe "PlayerView::#{name}", ->

      local = "_#{name}"

      it "#{name} should be a lazyily constructed #{View.name}", ->
        view = new PlayerView model: model
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(subview instanceof View).toBe true
        expect(view[local]).toBe subview

      it "#{name} should remain the same once contrsucted", ->
        view = new PlayerView model: model
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(view[local]).toBe subview
        expect(view[name]()).toBe subview
        expect(view[name]()).toBe subview

      it "#{name} should be re-constructed if deleted", ->
        view = new PlayerView model: model
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(view[local]).toBe subview
        expect(view[name]()).toBe subview

        view[local] = undefined
        expect(view[local]).not.toBeDefined()

        subview2 = view[name]()
        expect(view[local]).toBe subview2
        expect(view[name]()).toBe subview2
        expect(subview).not.toBe subview2

  describePlayerSubiew 'editorView', acorn.player.EditorView
  describePlayerSubiew 'splashView', acorn.player.SplashView
  describePlayerSubiew 'contentView', acorn.player.ContentView


  describe 'events', ->

    it 'should show EditorView on eventhub `show:editor`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      expect(view.content() instanceof acorn.player.EditorView).toBe false
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true

    it 'should show ContentView on eventhub `show:content`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      expect(view.content() instanceof acorn.player.ContentView).toBe false
      hub.trigger 'show:content'
      expect(view.content() instanceof acorn.player.ContentView).toBe true

    it 'should show SplashView on eventhub `show:splash`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      hub.trigger 'show:content'
      expect(view.content() instanceof acorn.player.SplashView).toBe false
      hub.trigger 'show:splash'
      expect(view.content() instanceof acorn.player.SplashView).toBe true



  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a PlayerView into the DOM to see how it looks.
    view = new PlayerView model: model
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el

    view.eventhub.trigger 'show:splash'
