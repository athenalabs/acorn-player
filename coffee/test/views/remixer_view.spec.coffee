goog.provide 'acorn.specs.player.RemixerView'

goog.require 'acorn.player.RemixerView'

describe 'acorn.player.RemixerView', ->
  RemixerView = acorn.player.RemixerView
  EventSpy = athena.lib.util.test.EventSpy

  describeView = athena.lib.util.test.describeView
  describeView RemixerView, athena.lib.View

  it 'should be part of acorn.player', ->
    expect(RemixerView).toBeDefined()

  describe 'RemixerView::remixerSubview', ->

    it 'should be fine with no remixerSubview', ->
      view = new RemixerView
      expect(view.remixerSubview).not.toBeDefined()
      expect(view.render).not.toThrow()
      expect(view.remixerSubview).not.toBeDefined()

    it 'should render and append remixerSubview on render', ->
      view = new RemixerView
      view.remixerSubview = new athena.lib.View
      view.render()
      expect(view.remixerSubview.rendering).toBe true
      expect(view.remixerSubview.el.parentNode.parentNode).toBe view.el


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new RemixerView
    view.$el.width 600
    view.render()
    $player.append view.el
