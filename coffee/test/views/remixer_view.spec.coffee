goog.provide 'acorn.specs.player.RemixerView'

goog.require 'acorn.player.RemixerView'
goog.require 'acorn.shells.Shell'
goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.ImageLinkShell'
goog.require 'acorn.shells.TextShell'

describe 'acorn.player.RemixerView', ->
  RemixerView = acorn.player.RemixerView
  EventSpy = athena.lib.util.test.EventSpy

  Shell = acorn.shells.Shell
  EmptyShell = acorn.shells.EmptyShell
  LinkShell = acorn.shells.LinkShell
  ImageLinkShell = acorn.shells.ImageLinkShell
  TextShell = acorn.shells.TextShell
  ToolbarView = athena.lib.ToolbarView

  # construction options
  model = new Shell.Model

  viewOptions = (opts = {}) ->
    _.defaults opts,
      model: new Shell.Model
      eventhub: new Backbone.View

  it 'should be part of acorn.player', ->
    expect(RemixerView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView RemixerView, athena.lib.View, viewOptions()


  describeSubview = athena.lib.util.test.describeSubview
  describeSubview
    View: RemixerView
    Subview: acorn.player.DropdownView
    subviewAttr: 'dropdownView'
    viewOptions: viewOptions()
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode.parentNode is pEl


  describeSubview {
    View: RemixerView
    Subview: ToolbarView
    subviewAttr: 'toolbarView'
    viewOptions: viewOptions()
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode.parentNode is pEl
  }, ->

    it 'should be initialized with remixerView.toolbarButtons', ->
      spyOn ToolbarView::, 'initialize'
      expect(ToolbarView::initialize).not.toHaveBeenCalled()

      view = new RemixerView viewOptions toolbarButtons: 'fakeButtons'
      expect(view.options.toolbarButtons).toBe 'fakeButtons'


  describeSubview {
    View: RemixerView
    Subview: acorn.player.SummaryView
    subviewAttr: 'summarySubview'
    viewOptions: viewOptions()
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode is pEl
  }, ->

    it 'should be initialized if options.showSummary is true', ->
      view = new RemixerView viewOptions showSummary: true
      expect(view.summarySubview).toBeDefined()

    it 'should not be initialized if options.showSummary is false', ->
      view = new RemixerView viewOptions showSummary: false
      expect(view.summarySubview).not.toBeDefined()


  describeSubview
    View: RemixerView
    Subview: model.module.RemixView
    subviewAttr: 'remixSubview'
    viewOptions: viewOptions()
    checkDOM: (cEl, pEl) -> cEl.parentNode.parentNode is pEl


  describe 'RemixerView: link field', ->

    it 'should be an uneditable-input span if RemixView.activeLinkInput is
        false', ->
      oldValue = Shell.RemixView.activeLinkInput
      @after = -> Shell.RemixView.activeLinkInput = oldValue
      Shell.RemixView.activeLinkInput = false

      view = new RemixerView viewOptions()
      view.render()

      expect(view.$('#link').length).toBe 1
      expect(view.$('span#link').length).toBe 1
      expect(view.$('span#link').hasClass 'uneditable-input').toBe true

    it 'should be an input field if RemixView.activeLinkInput is true', ->
      oldValue = Shell.RemixView.activeLinkInput
      @after = -> Shell.RemixView.activeLinkInput = oldValue
      Shell.RemixView.activeLinkInput = true

      view = new RemixerView viewOptions()
      view.render()

      expect(view.$('#link').length).toBe 1
      expect(view.$('input#link').length).toBe 1


  describe 'RemixerView::setToolbarButtons', ->

    it 'should set toolbarButtons to @options.toolbarButtons by default', ->
      view = new RemixerView viewOptions()
      view.toolbarButtons = 'fakeButtons'
      view.options.toolbarButtons = 'realButtons'

      # stub toolbarView reinitialization
      spyOn view, '_initializeToolbarView'

      expect(view.toolbarButtons).not.toBe 'realButtons'
      view.setToolbarButtons()
      expect(view.toolbarButtons).toBe 'realButtons'

    it 'should set toolbarButtons to passed in param if available', ->
      view = new RemixerView viewOptions()
      view.toolbarButtons = 'fakeButtons'

      # stub toolbarView reinitialization
      spyOn view, '_initializeToolbarView'

      expect(view.toolbarButtons).not.toBe 'realButtons'
      view.setToolbarButtons 'realButtons'
      expect(view.toolbarButtons).toBe 'realButtons'

    it 'should reinitialize toolbarView', ->
      view = new RemixerView viewOptions()
      spyOn view, '_initializeToolbarView'

      expect(view._initializeToolbarView).not.toHaveBeenCalled()
      view.setToolbarButtons()
      expect(view._initializeToolbarView).toHaveBeenCalled()

    it 'should rerender toolbarView if rendering', ->
      view = new RemixerView viewOptions()
      view.render()
      spyOn view, 'renderToolbarView'

      expect(view.renderToolbarView).not.toHaveBeenCalled()
      view.setToolbarButtons()
      expect(view.renderToolbarView).toHaveBeenCalled()

    it 'should not rerender toolbarView if not rendering', ->
      view = new RemixerView viewOptions()
      spyOn view, 'renderToolbarView'

      expect(view.renderToolbarView).not.toHaveBeenCalled()
      view.setToolbarButtons()
      expect(view.renderToolbarView).not.toHaveBeenCalled()


  describe 'events', ->

    it 'should trigger `Remixer:Toolbar:Click:Clear` on clicking btn', ->
      view = new RemixerView viewOptions()
      spy = new EventSpy view, 'Remixer:Toolbar:Click:Clear'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#Clear').trigger 'click'
      expect(spy.triggered).toBe true
      expect(spy.arguments[0]).toEqual [view]

    it 'should reset to empty shell on `Toolbar:Click:Clear` event', ->
      view = new RemixerView viewOptions()
      view.render()

      expect(view.model instanceof EmptyShell.Model).toBe false
      view.toolbarView.trigger 'Toolbar:Click:Clear'
      expect(view.model instanceof EmptyShell.Model).toBe true

    it 'should trigger `Remixer:Toolbar:Click:Duplicate` on clicking btn', ->
      view = new RemixerView viewOptions()
      spy = new EventSpy view, 'Remixer:Toolbar:Click:Duplicate'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#Duplicate').trigger 'click'
      expect(spy.triggered).toBe true
      expect(spy.arguments[0]).toEqual [view]

    it 'should trigger `Remixer:Toolbar:Click:Delete` on clicking btn', ->
      view = new RemixerView viewOptions()
      spy = new EventSpy view, 'Remixer:Toolbar:Click:Delete'

      view.render()
      expect(spy.triggered).toBe false
      view.toolbarView.$('button#Delete').trigger 'click'
      expect(spy.triggered).toBe true
      expect(spy.arguments[0]).toEqual [view]

    it 'should trigger `Remixer:SwapShell` on dropdown select', ->
      model = new LinkShell.Model
      view = new RemixerView model: model
      spy1 = new EventSpy view.dropdownView, 'Dropdown:Selected'
      spy2 = new EventSpy view, 'Remixer:SwapShell'

      view.render()
      expect(spy1.triggered).toBe false
      expect(spy2.triggered).toBe false
      view.dropdownView.selected ImageLinkShell.id
      expect(spy1.triggered).toBe true
      expect(spy2.triggered).toBe true
      expect(spy2.arguments[0]).toEqual [view, model, view.model]
      expect(model).not.toEqual view.model

    it 'should not trigger `Remixer:SwapShell` if dropdown select is same', ->
      model = new LinkShell.Model
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
      model = new ImageLinkShell.Model
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
      model = new LinkShell.Model
      model2 = new TextShell.Model
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
      model = new LinkShell.Model
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
      model = new ImageLinkShell.Model
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
      model = new LinkShell.Model
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

    view = new RemixerView viewOptions()
    view.$el.width 600
    view.render()
    $player.append view.el

    view = new RemixerView viewOptions
      toolbarButtons: []
      validShells: [ImageLinkShell]

    view.$el.width 600
    view.render()
    $player.append view.el
