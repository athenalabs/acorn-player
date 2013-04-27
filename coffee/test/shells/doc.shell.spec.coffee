goog.provide 'acorn.specs.shells.DocShell'

goog.require 'acorn.shells.DocShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.DocShell', ->
  text = athena.lib.util.test
  TextShell = acorn.shells.TextShell
  DocShell = acorn.shells.DocShell

  it 'should be part of acorn.shells', ->
    expect(DocShell).toBeDefined()

  acorn.util.test.describeShellModule DocShell, ->

    options =
      model: new DocShell.Model
        shellid: 'acorn.DocShell'

    describe 'DocShell.MediaView', ->

      test.describeSubview
        View: DocShell.MediaView
        Subview: athena.lib.DocView
        subviewAttr: 'docView'
        viewOptions: options


  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    model = new DocShell.Model
      shellid: 'acorn.DocShell'
      text: '''
        # Cosmos
        > The Cosmos is *all* that is or ever was or ever will be.
        > Our feeblest contemplations of the Cosmos stir us —
        > there is a tingling in the spine, a catch in the voice,
        > a faint sensation as if a distant memory,
        > of falling from a height.
        > We know we are approaching the greatest of mysteries.
        - Carl Sagan, Cosmos 1980
        '''

    contentView = new DocShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new DocShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
