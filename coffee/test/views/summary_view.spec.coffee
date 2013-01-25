goog.provide 'acorn.specs.player.SummaryView'
goog.require 'acorn.player.SummaryView'

describe 'acorn.player.ShellEditorView', ->
  test = athena.lib.util.test

  SummaryView = acorn.player.SummaryView
  TextShell = acorn.shells.TextShell

  # model for EditorView contruction
  model = new TextShell.Model
    title: 'Title'
    description: 'Description'

  options = model: model


  it 'should be part of acorn.player', ->
    expect(SummaryView).toBeDefined()

  test.describeView SummaryView, athena.lib.View, options

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new SummaryView options
    view.render()
    $player.append view.el
