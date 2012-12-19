goog.provide 'acorn.specs.player.RemixerView'

goog.require 'acorn.player.RemixerView'
goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.ImageLinkShell'

describe 'acorn.player.RemixerView', ->
  RemixerView = acorn.player.RemixerView
  EventSpy = athena.lib.util.test.EventSpy

  # construction options
  model = new acorn.shells.Shell.Model

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

    it 'should trigger `Remixer:SwapShell` on dropdown select', ->
      model = new acorn.shells.LinkShell.Model
      view = new RemixerView model: model
      spy1 = new EventSpy view.dropdownView, 'Dropdown:Selected'
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1.triggered).toBe false
      expect(spy2.triggered).toBe false
      view.dropdownView.selected acorn.shells.ImageLinkShell.id
      expect(spy1.triggered).toBe true
      expect(spy2.triggered).toBe true
      expect(spy2.arguments[0]).toEqual [view, model, view.model]
      expect(model).not.toEqual view.model

    it 'should not trigger `Remixer:SwapShell` if dropdown select is same', ->
      model = new acorn.shells.LinkShell.Model
      view = new RemixerView model: model
      spy1 = new EventSpy view, 'Remixer:SwapShell'
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1.triggered).toBe false
      expect(spy2.triggered).toBe false
      view.dropdownView.selected model.shellid()
      expect(spy1.triggered).toBe false
      expect(spy2.triggered).toBe false

    it 'should trigger `Remixer:SwapShell` on editing link input', ->
      model = new acorn.shells.ImageLinkShell.Model
      view = new RemixerView model: model
      spy1 = spyOn(view, 'onBlurLink').andCallThrough()
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1).not.toHaveBeenCalled()
      expect(spy2.triggered).toBe false

      view.$('input#link').val 'http://athena.ai'
      view.$('input#link').trigger 'blur'
      expect(spy1).toHaveBeenCalled()
      expect(spy2.triggered).toBe true
      expect(model).not.toEqual view.model

    it 'should not trigger `Remixer:SwapShell` on link change (same shell)', ->
      model = new acorn.shells.LinkShell.Model
      view = new RemixerView model: model
      spy1 = spyOn(view, 'onBlurLink').andCallThrough()
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1).not.toHaveBeenCalled()
      expect(spy2.triggered).toBe false

      view.$('input#link').val 'http://athena.ai'
      view.$('input#link').trigger 'blur'
      expect(spy1).toHaveBeenCalled()
      expect(spy2.triggered).toBe false
      expect(view.model.link()).toBe 'http://athena.ai'



  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new RemixerView options
    view.$el.width 600
    view.render()
    $player.append view.el
