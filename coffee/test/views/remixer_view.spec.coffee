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

  describeSubview {
    View: RemixerView
    Subview: acorn.player.SummaryView
    subviewAttr: 'summarySubview'
    viewOptions: options
  }, ->

    it 'should be initialized if options.showSummary is true', ->
      view = new RemixerView _.extend {}, options, {showSummary: true}
      expect(view.summarySubview).toBeDefined()

    it 'should not be initialized if options.showSummary is false', ->
      view = new RemixerView _.extend {}, options, {showSummary: false}
      expect(view.summarySubview).not.toBeDefined()


  describeSubview
    View: RemixerView
    Subview: model.module.RemixView
    subviewAttr: 'remixSubview'
    viewOptions: options
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode is pEl

  describe 'events', ->

    it 'should trigger `Remixer:Toolbar:Click:Duplicate` on clicking btn', ->
      view = new RemixerView options
      spy = new EventSpy view, 'Remixer:Toolbar:Click:Duplicate'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#Duplicate').trigger 'click'
      expect(spy.triggered).toBe true
      expect(spy.arguments[0]).toEqual [view]

    it 'should trigger `Remixer:Toolbar:Click:Delete` on clicking btn', ->
      view = new RemixerView options
      spy = new EventSpy view, 'Remixer:Toolbar:Click:Delete'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#Delete').trigger 'click'
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
      spy1 = spyOn(view, 'onLinkChange').andCallThrough()
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1).not.toHaveBeenCalled()
      expect(spy2.triggered).toBe false

      view.$('input#link').val 'http://athena.ai'
      view.$('input#link').trigger 'blur'
      expect(spy1).toHaveBeenCalled()
      expect(spy2.triggered).toBe true
      expect(model).not.toEqual view.model

    it 'should trigger `Remixer:SwapShell` on `Remix:SwapShell`', ->
      model = new acorn.shells.LinkShell.Model
      model2 = new acorn.shells.TextShell.Model
      view = new RemixerView model: model
      spy1 = new EventSpy view.dropdownView, 'Dropdown:Selected'
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1.triggered).toBe false
      expect(spy2.triggered).toBe false
      view.remixSubview.trigger 'Remix:SwapShell', model, model2
      expect(spy1.triggered).toBe true
      expect(spy2.triggered).toBe true
      expect(spy2.arguments[0]).toEqual [view, model, model2]
      expect(model).not.toEqual view.model
      expect(model2).toEqual view.model


    it 'should not trigger `Remixer:SwapShell` on link change (same shell)', ->
      model = new acorn.shells.LinkShell.Model
      view = new RemixerView model: model
      spy1 = spyOn(view, 'onLinkChange').andCallThrough()
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1).not.toHaveBeenCalled()
      expect(spy2.triggered).toBe false

      view.$('input#link').val 'http://athena.ai'
      view.$('input#link').trigger 'blur'
      expect(spy1).toHaveBeenCalled()
      expect(spy2.triggered).toBe false
      expect(view.model.link()).toBe 'http://athena.ai'

    it 'should trigger `Remixer:LinkShell` on editing link (diff shell)', ->
      model = new acorn.shells.ImageLinkShell.Model
      view = new RemixerView model: model
      spy1 = spyOn(view, 'onLinkChange').andCallThrough()
      spy2 = new EventSpy view, 'Remixer:LinkChanged'

      view.render()
      expect(spy1).not.toHaveBeenCalled()
      expect(spy2.triggered).toBe false

      view.$('input#link').val 'http://athena.ai'
      view.$('input#link').trigger 'blur'
      expect(spy1).toHaveBeenCalled()
      expect(spy2.triggered).toBe true
      expect(spy2.arguments[0]).toEqual [view, 'http://athena.ai']
      expect(model).not.toEqual view.model

    it 'should trigger `Remixer:LinkChanged` on link change (same shell)', ->
      model = new acorn.shells.LinkShell.Model
      view = new RemixerView model: model
      spy1 = spyOn(view, 'onLinkChange').andCallThrough()
      spy2 = new EventSpy view, 'Remixer:LinkChanged'

      view.render()
      expect(spy1).not.toHaveBeenCalled()
      expect(spy2.triggered).toBe false

      view.$('input#link').val 'http://athena.ai'
      view.$('input#link').trigger 'blur'
      expect(spy1).toHaveBeenCalled()
      expect(spy2.triggered).toBe true
      expect(spy2.arguments[0]).toEqual [view, 'http://athena.ai']
      expect(view.model.link()).toBe 'http://athena.ai'



  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new RemixerView options
    view.$el.width 600
    view.render()
    $player.append view.el

    view = new RemixerView _.extend {}, options,
      toolbarButtons: []
      validShells: [acorn.shells.ImageLinkShell]

    view.$el.width 600
    view.render()
    $player.append view.el
