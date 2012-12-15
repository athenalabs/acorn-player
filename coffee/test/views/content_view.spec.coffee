goog.provide 'acorn.specs.player.ContentView'

goog.require 'acorn.player.ContentView'

describe 'acorn.player.ContentView', ->
  ContentView = acorn.player.ContentView

  # model for ContentView contruction
  model =
    acornModel: new Backbone.Model
    shellModel: new Backbone.Model

  # emulate shell, object with a ContentView property
  module = ContentView: athena.lib.View
  model.shellModel.module = module
  module.ContentView::controls = [
    IconControlView.withIcon 'play',
    IconControlView.withIcon 'pause',
    IconControlView.withIcon 'stop',
  ]

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(ContentView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ContentView, athena.lib.View, options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: module.ContentView
    subviewAttr: 'shellView'
    viewOptions: options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: ControlToolbarView
    subviewAttr: 'controlsView'
    viewOptions: options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: ControlToolbarView
    subviewAttr: 'acornControlsView'
    viewOptions: options
    checkDOM: (childEl, parentEl) -> childEl.parentNode.parentNode is parentEl

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: ControlToolbarView
    subviewAttr: 'shellControlsView'
    viewOptions: options
    checkDOM: (childEl, parentEl) -> childEl.parentNode.parentNode is parentEl

  it 'should render controlsView before shellView', ->
    contentView = new ContentView options
    callStack = []

    controlsSpy = spyOn(contentView.controlsView, 'render')
        .andCallFake(-> callStack.push 'controlsView.render')
    shellSpy = spyOn(contentView.shellView, 'render')
        .andCallFake(-> callStack.push 'shellView.render')

    contentView.render()
    expect(callStack[0]).toBe 'controlsView.render'
    expect(callStack[1]).toBe 'shellView.render'

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
