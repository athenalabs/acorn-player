goog.provide 'acorn.specs.player.EditImageView'
goog.require 'acorn.player.EditImageView'
goog.require 'acorn.shells.TextShell'

describe 'acorn.player.ShellEditorView', ->
  test = athena.lib.util.test

  EditImageView = acorn.player.EditImageView
  ImageLinkShell = acorn.shells.ImageLinkShell

  options = model: new ImageLinkShell.Model


  it 'should be part of acorn.player', ->
    expect(EditImageView).toBeDefined()

  test.describeView EditImageView, athena.lib.View, options


  test.describeSubview {
    View: EditImageView
    Subview: acorn.player.RemixerView
    subviewAttr: 'remixerView'
    viewOptions: options
  }, ->

    it 'should fire `EditImage:Cancel` on `Remixer:Toolbar:Click:Cancel`', ->
      view = new EditImageView options
      view.render()
      spy = new test.EventSpy view, 'EditImage:Cancel'
      view.remixerView.$('button#Cancel').trigger 'click'
      expect(spy.triggered).toBe true

    it 'should fire `EditImage:Save` on `Remixer:Toolbar:Click:Save`', ->
      view = new EditImageView options
      view.render()
      spy = new test.EventSpy view, 'EditImage:Cancel'
      view.remixerView.$('button#Cancel').trigger 'click'
      expect(spy.triggered).toBe true


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new EditImageView options
    view.render()
    $player.append view.el
