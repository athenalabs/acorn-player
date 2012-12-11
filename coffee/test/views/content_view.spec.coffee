goog.provide 'acorn.specs.player.ContentView'

goog.require 'acorn.player.ContentView'

describe 'acorn.player.ContentView', ->
  ContentView = acorn.player.ContentView

  # options for ContentView contruction
  options =
    model: new Backbone.Model

  # emulate shell, object with a ContentView property
  options.model.shell =
      ContentView: athena.lib.View

  it 'should be part of acorn.player', ->
    expect(acorn.player.ContentView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ContentView, athena.lib.View).toBe true

  it 'should instantiate and render a shell.ContentView', ->
    view = new ContentView options

    expect(view.shellView).not.toBeDefined()
    view.render()
    expect(view.shellView).toBeDefined()
    expect(view.shellView instanceof options.model.shell.ContentView).toBe true
    expect(view.shellView.rendering).toBe true
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
