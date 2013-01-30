goog.provide 'acorn.specs.player.ShellOptionsView'

goog.require 'acorn.player.ShellOptionsView'

describe 'acorn.player.ShellOptionsView', ->
  test = athena.lib.util.test
  ShellOptionsView = acorn.player.ShellOptionsView

  # shell model for ShellOptionsView contruction
  model = new acorn.shells.Shell.Model
    shellid: 'acorn.Shell'

  # options for ShellOptionsView contruction
  options = model: model

  it 'should be part of acorn.player', ->
    expect(ShellOptionsView).toBeDefined()

  describeView = test.describeView
  describeView ShellOptionsView, athena.lib.View, options

  test.describeSubview
    View: ShellOptionsView
    Subview: acorn.player.DropdownView
    subviewAttr: 'dropdownView'
    viewOptions: options

  test.describeSubview
    View: ShellOptionsView
    Subview: model.module.RemixView
    subviewAttr: 'remixView'
    viewOptions: options

  it 'should trigger `ShellOptions:SwapShell` on Dropdown:Selected', ->
    view = new ShellOptionsView options
    view.render()
    spy = new test.EventSpy view, 'ShellOptions:SwapShell'
    view.dropdownView.selected('acorn.EmptyShell')
    expect(spy.triggered).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a ShellOptionsView into the DOM to see how it looks.
    model = new athena.lib.Model

    view = new ShellOptionsView options
    view.$el.width 600
    view.$el.height 200
    view.render()
    $player.append view.el
