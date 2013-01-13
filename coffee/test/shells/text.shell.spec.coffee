goog.provide 'acorn.specs.shells.TextShell'

goog.require 'acorn.shells.TextShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.TextShell', ->
  Shell = acorn.shells.Shell
  TextShell = acorn.shells.TextShell

  it 'should be part of acorn.shells', ->
    expect(TextShell).toBeDefined()

  acorn.util.test.describeShellModule TextShell

  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    model = new TextShell.Model
      shellid: 'acorn.TextShell'
      text: '''
        The Cosmos is all that is or ever was or ever will be.
        Our feeblest contemplations of the Cosmos stir us —
        there is a tingling in the spine, a catch in the voice,
        a faint sensation as if a distant memory,
        of falling from a height.
        We know we are approaching the greatest of mysteries.
        - Carl Sagan, Cosmos 1980
        '''

    contentView = new TextShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new TextShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
