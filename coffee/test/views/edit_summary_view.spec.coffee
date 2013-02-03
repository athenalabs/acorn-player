goog.provide 'acorn.specs.player.EditSummaryView'
goog.require 'acorn.player.EditSummaryView'
goog.require 'acorn.shells.TextShell'

describe 'acorn.player.EditSummaryView', ->
  test = athena.lib.util.test

  EditSummaryView = acorn.player.EditSummaryView
  TextShell = acorn.shells.TextShell

  # model for EditorView contruction
  model = new TextShell.Model
    title: 'Title of the Best Acorn Ever'
    description: 'Description of the Best Acorn Ever: this acorn is the
      absolute best acorn ever, \'tis true. Description of the Best Acorn Ever:
      this acorn is the absolute best acorn ever, \'tis true.'

  options = model: model


  it 'should be part of acorn.player', ->
    expect(EditSummaryView).toBeDefined()


  test.describeView EditSummaryView, acorn.player.SummaryView, options


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new EditSummaryView options
    view.render()
    $player.append view.el
