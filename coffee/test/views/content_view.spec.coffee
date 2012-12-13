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

  describeView = athena.lib.util.test.describeView
  describeView ContentView, athena.lib.View, options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: shell.ContentView
    subviewAttr: 'shellView'
    viewOptions: options


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
