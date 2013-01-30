goog.provide 'acorn.specs.shells.EmptyShell'

goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.EmptyShell', ->
  Shell = acorn.shells.Shell
  EmptyShell = acorn.shells.EmptyShell

  it 'should be part of acorn.shells', ->
    expect(EmptyShell).toBeDefined()

  acorn.util.test.describeShellModule EmptyShell

  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    model = new EmptyShell.Model
      shellid: 'acorn.EmptyShell'

    contentView = new EmptyShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new EmptyShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
