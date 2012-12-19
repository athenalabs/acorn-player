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

  it 'should be part of acorn.player', ->
    expect(RemixerView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView RemixerView, athena.lib.View, options

  describeSubview = athena.lib.util.test.describeSubview
  describeSubview
    View: RemixerView
    Subview: acorn.player.DropdownView
    subviewAttr: 'dropdownView'
    viewOptions: options
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode.parentNode is pEl

  describeSubview
    View: RemixerView
    Subview: athena.lib.ToolbarView
    subviewAttr: 'toolbarView'
    viewOptions: options
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode is pEl

  describeSubview
    View: RemixerView
    Subview: model.module.RemixView
    subviewAttr: 'remixSubview'
    viewOptions: options
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode is pEl

  describe 'events', ->

    it 'should trigger `Remixer:Duplicate` on clicking btn', ->
      view = new RemixerView options
      spy = new EventSpy view, 'Remixer:Duplicate'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#duplicate').trigger 'click'
      expect(spy.triggered).toBe true
      expect(spy.arguments[0]).toEqual [view]

    it 'should trigger `Remixer:Delete` on clicking btn', ->
      view = new RemixerView options
      spy = new EventSpy view, 'Remixer:Delete'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#delete').trigger 'click'
      expect(spy.triggered).toBe true
      expect(spy.arguments[0]).toEqual [view]

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new RemixerView options
    view.$el.width 600
    view.render()
    $player.append view.el
