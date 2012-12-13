goog.provide 'acorn.specs.player.ContentView'

goog.require 'acorn.player.ContentView'

describe 'acorn.player.ContentView', ->
  ContentView = acorn.player.ContentView

  # model for ContentView contruction
  model =
    acornModel: new Backbone.Model
    shellModel: new Backbone.Model

  # emulate shell, object with a ContentView property
  shell = ContentView: athena.lib.View
  model.shellModel.shell = shell

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(acorn.player.ContentView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ContentView, athena.lib.View).toBe true

  describe 'ContentView::shellView subview', ->

    it 'should NOT be defined on init', ->
      view = new ContentView options
      expect(view.shellView).not.toBeDefined()

    it 'should be defined on render', ->
      view = new ContentView options
      view.render()
      expect(view.shellView).toBeDefined()

    it 'should be an instanceof shell.ContentView', ->
      view = new ContentView options
      view.render()
      expect(view.shellView instanceof shell.ContentView).toBe true

    it 'should be rendering with its parent', ->
      view = new ContentView options
      view.render()
      expect(view.shellView.rendering).toBe true

    it 'should be a DOM child of its parent', ->
      view = new ContentView options
      view.render()
      expect(view.shellView.el.parentNode).toEqual view.el

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new ContentView options
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el

    view.shellView.$el.append $('<img>').attr 'src', acorn.config.img.acorn
