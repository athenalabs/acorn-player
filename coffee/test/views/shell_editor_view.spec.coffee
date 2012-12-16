goog.provide 'acorn.specs.player.ShellEditorView'

goog.require 'acorn.player.ShellEditorView'

describe 'acorn.player.ShellEditorView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ShellEditorView = acorn.player.ShellEditorView
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  # model for EditorView contruction
  model = new acorn.shells.Shell.Model
    shellid: 'acorn.Shell'

  # options for EditorView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(ShellEditorView).toBeDefined()

  describeView ShellEditorView, athena.lib.View, options

  describeSubview
    View: ShellEditorView
    Subview: acorn.player.ShellOptionsView
    subviewAttr: 'shellOptionsView'
    viewOptions: options

  describeSubview
    View: ShellEditorView
    Subview: acorn.player.RemixerView
    subviewAttr: 'newRemixerView'
    viewOptions: options

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new ShellEditorView options
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
