goog.provide 'acorn.specs.player.RemixerView'

goog.require 'acorn.player.RemixerView'

describe 'acorn.player.RemixerView', ->
  RemixerView = acorn.player.RemixerView
  EventSpy = athena.lib.util.test.EventSpy

  # construction options
  model = new acorn.shells.Shell.Model
    shellid: 'acorn.Shell'

  options =
    model: model

  describeView = athena.lib.util.test.describeView
  describeView RemixerView, athena.lib.View, options

  it 'should be part of acorn.player', ->
    expect(RemixerView).toBeDefined()

  describe 'RemixerView::remixerSubview', ->
    it 'should be fine with no remixerSubview', ->
      view = new RemixerView options
      expect(view.remixerSubview).not.toBeDefined()
      expect(view.render).not.toThrow()
      expect(view.remixerSubview).not.toBeDefined()

    it 'should render and append remixerSubview on render', ->
      view = new RemixerView options
      view.remixerSubview = new athena.lib.View
      view.render()
      expect(view.remixerSubview.rendering).toBe true
      expect(view.remixerSubview.el.parentNode.parentNode).toBe view.el


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new RemixerView options
    view.$el.width 600
    view.render()
    $player.append view.el
