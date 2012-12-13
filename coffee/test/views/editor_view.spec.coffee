goog.provide 'acorn.specs.player.EditorView'

goog.require 'acorn.player.EditorView'

describe 'acorn.player.EditorView', ->
  EditorView = acorn.player.EditorView

  # model for ContentView contruction
  model =
    acornModel: new Backbone.Model
      thumbnail: acorn.config.img.acorn
      acornid: 'nyfskeqlyx'
      title: 'The Differential'
    shellModel: new Backbone.Model

  # emulate shell, object with a ContentView property
  shell = ContentView: athena.lib.View
  model.shellModel.shell = shell

  # options for ContentView contruction
  options = model: model

  it 'should be part of acorn.player', ->
    expect(acorn.player.EditorView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives EditorView, athena.lib.View).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new EditorView options
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
