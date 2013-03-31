goog.provide 'acorn.specs.player.ShellEditorView'

goog.require 'acorn.player.ShellEditorView'
goog.require 'acorn.shells.TextShell'
goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.shells.GalleryShell'
goog.require 'acorn.shells.CollectionShell'

describe 'acorn.player.ShellEditorView', ->
  test = athena.lib.util.test
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  Shell = acorn.shells.Shell
  TextShell = acorn.shells.TextShell
  EmptyShell = acorn.shells.EmptyShell
  GalleryShell = acorn.shells.GalleryShell
  CollectionShell = acorn.shells.CollectionShell
  ShellEditorView = acorn.player.ShellEditorView

  model = new TextShell.Model
  eventhub = new Backbone.View

  # options for EditorView contruction
  viewOptions = (opts = {}) ->
    _.defaults opts,
      model: model
      eventhub: eventhub


  it 'should be part of acorn.player', ->
    expect(ShellEditorView).toBeDefined()

  describeView ShellEditorView, athena.lib.View, viewOptions()


  describe 'construction', ->

    it 'should set model to an instance of defaultShell.Model if no model is
        given', ->
      opts = viewOptions()
      delete opts.model
      view = new ShellEditorView opts
      expect(view.model instanceof view.defaultShell.Model).toBe true


  describe 'ShellEditorView::remixerViews', ->
    # below, tests marked `(added)` add another shell after construction
    # and even after rendering, to ensure the suviews work well given
    # shell additions.

    it 'should be an array defined on init', ->
      view = new ShellEditorView viewOptions()
      expect(view.remixerViews).toBeDefined()
      expect(_.isArray view.remixerViews).toBe true

    it 'should be an array of length 1', ->
      view = new ShellEditorView viewOptions()
      expect(view.remixerViews).toBeDefined()
      expect(view.remixerViews.length).toBe 1

    it "should contain an instance of RemixerView", ->
      view = new ShellEditorView viewOptions()
      expect(view.remixerViews[0] instanceof acorn.player.RemixerView).toBe true

    it 'should not be rendering initially', ->
      view = new ShellEditorView viewOptions()
      expect(view.remixerViews[0].rendering).toBe false

    it "should be rendering with ShellEditorView", ->
      view = new ShellEditorView viewOptions()
      view.render()
      expect(view.remixerViews[0].rendering).toBe true

    it "should be DOM descendants of the ShellEditorView", ->
      view = new ShellEditorView viewOptions()
      view.render()
      expect(view.remixerViews[0].el.parentNode.parentNode).toBe view.el


  describe 'ShellEditorView::render', ->

    it 'should call _renderHeader', ->
      view = new ShellEditorView viewOptions()
      spyOn(view, '_renderHeader').andCallThrough()

      expect(view._renderHeader).not.toHaveBeenCalled()
      view.render()
      expect(view._renderHeader).toHaveBeenCalled()

    it 'should call _renderRemixerViews', ->
      view = new ShellEditorView viewOptions()
      spyOn(view, '_renderRemixerViews').andCallThrough()

      expect(view._renderRemixerViews).not.toHaveBeenCalled()
      view.render()
      expect(view._renderRemixerViews).toHaveBeenCalled()

    it 'should call _renderFooter', ->
      view = new ShellEditorView viewOptions()
      spyOn(view, '_renderFooter').andCallThrough()

      expect(view._renderFooter).not.toHaveBeenCalled()
      view.render()
      expect(view._renderFooter).toHaveBeenCalled()

    it 'should call _renderUpdates', ->
      view = new ShellEditorView viewOptions()
      spyOn(view, '_renderUpdates').andCallThrough()

      expect(view._renderUpdates).not.toHaveBeenCalled()
      view.render()
      expect(view._renderUpdates).toHaveBeenCalled()

    it 'should render header, remixerViews, footer, and updates, in order', ->
      view = new ShellEditorView viewOptions()
      callStack = []
      spyOn(view, '_renderHeader').andCallFake -> callStack.push 'header'
      spyOn(view, '_renderRemixerViews').andCallFake -> callStack.push 'remixer'
      spyOn(view, '_renderFooter').andCallFake -> callStack.push 'footer'
      spyOn(view, '_renderUpdates').andCallFake -> callStack.push 'updates'

      view.render()
      expect(callStack[0]).toBe 'header'
      expect(callStack[1]).toBe 'remixer'
      expect(callStack[2]).toBe 'footer'
      expect(callStack[3]).toBe 'updates'


  describe 'ShellEditorView::_renderRemixerViews', ->

    it 'should pass each remixerView to _renderRemixerView', ->
      view = new ShellEditorView viewOptions()
      rvs = view.remixerViews = for i in [0..4]
        (new Backbone.View).render()
      spyOn view, '_renderRemixerView'

      expect(view._renderRemixerView).not.toHaveBeenCalled()
      view._renderRemixerViews()
      expect(view._renderRemixerView).toHaveBeenCalled()
      expect(view._renderRemixerView.callCount).toBe 5
      expect(view._renderRemixerView.argsForCall[0][0]).toBe rvs[0]
      expect(view._renderRemixerView.argsForCall[1][0]).toBe rvs[1]
      expect(view._renderRemixerView.argsForCall[2][0]).toBe rvs[2]
      expect(view._renderRemixerView.argsForCall[3][0]).toBe rvs[3]
      expect(view._renderRemixerView.argsForCall[4][0]).toBe rvs[4]


  describe 'ShellEditorView::_renderUpdates', ->

    it 'should pass each remixerView to _renderRemixerViewHeading', ->
      view = new ShellEditorView viewOptions()
      view.render()
      rvs = view.remixerViews = for i in [0..4]
        (new Backbone.View).render()
      spyOn view, '_renderRemixerViewHeading'

      expect(view._renderRemixerViewHeading).not.toHaveBeenCalled()
      view._renderUpdates()
      expect(view._renderRemixerViewHeading).toHaveBeenCalled()
      expect(view._renderRemixerViewHeading.callCount).toBe 5
      expect(view._renderRemixerViewHeading.argsForCall[0][0]).toBe rvs[0]
      expect(view._renderRemixerViewHeading.argsForCall[1][0]).toBe rvs[1]
      expect(view._renderRemixerViewHeading.argsForCall[2][0]).toBe rvs[2]
      expect(view._renderRemixerViewHeading.argsForCall[3][0]).toBe rvs[3]
      expect(view._renderRemixerViewHeading.argsForCall[4][0]).toBe rvs[4]

    it 'should call _onThumbnailChange if thumbnail changed', ->
      view = new ShellEditorView viewOptions()
      spyOn view, '_onThumbnailChange'
      spyOn(view.model, 'thumbnail').andReturn 'model thumbnail'
      view._lastThumbnail = 'not model thumbnail'

      expect(view._onThumbnailChange).not.toHaveBeenCalled()
      view._renderUpdates()
      expect(view._onThumbnailChange).toHaveBeenCalled()

    it 'should not call _onThumbnailChange if thumbnail did not change', ->
      view = new ShellEditorView viewOptions()
      spyOn view, '_onThumbnailChange'
      spyOn(view.model, 'thumbnail').andReturn 'model thumbnail'
      view._lastThumbnail = 'model thumbnail'

      expect(view._onThumbnailChange).not.toHaveBeenCalled()
      view._renderUpdates()
      expect(view._onThumbnailChange).not.toHaveBeenCalled()


  describe 'ShellEditorView::_renderSectionHeading', ->

    it 'should be a function', ->
      expect(typeof ShellEditorView::_renderSectionHeading).toBe 'function'

    it 'should prepend an <h3> tag to the given view', ->
      view = new Backbone.View
      view.$el.append $ '<p>'
      expect(view.$('h3').length).toBe 0
      spyOn(ShellEditorView::, '_shellIsStub').andReturn true
      ShellEditorView::_renderSectionHeading view
      expect(view.$('h3').length).toBe 1
      expect(view.$('h3')[0]).toBe view.$el.children()[0]

    it 'should prepend an invitational message to stub remixers', ->
      view = new Backbone.View
      view.$el.append $ '<p>'
      expect(view.$('h3').length).toBe 0
      spyOn(ShellEditorView::, '_shellIsStub').andReturn true
      ShellEditorView::_renderSectionHeading view
      expect(view.$('h3').length).toBe 1
      expect(view.$('h3').text()).toBe 'add a media item by entering a link:'

    it 'should prepend the shell\'s module title to non-stub remixers', ->
      view = new Backbone.View
      view.$el.append $ '<p>'
      view.model = module: title: 'shell title'
      expect(view.$('h3').length).toBe 0
      spyOn(ShellEditorView::, '_shellIsStub').andReturn false
      ShellEditorView::_renderSectionHeading view
      expect(view.$('h3').length).toBe 1
      expect(view.$('h3').text()).toBe 'shell title'


  describe 'ShellEditorView::shell', ->

    it 'should return a clone of the model', ->
      view = new ShellEditorView viewOptions()
      spyOn(view.model, 'clone').andReturn 'cloned model'
      expect(view.shell()).toBe 'cloned model'


  describe 'ShellEditorView::isEmpty', ->

    it 'should return true if the model is a stub', ->
      view = new ShellEditorView viewOptions()
      spyOn(view, '_shellIsStub').andReturn true
      expect(view.isEmpty()).toBe true

    it 'should return false if the model is not a stub', ->
      view = new ShellEditorView viewOptions()
      spyOn(view, '_shellIsStub').andReturn false
      expect(view.isEmpty()).toBe false


  describe 'ShellEditorView::_shellIsStub', ->

    it 'should be a function', ->
      expect(typeof ShellEditorView::_shellIsStub).toBe 'function'

    it 'should return false if shell is not a defaultShell (EmptyShell)', ->
      view = new ShellEditorView viewOptions()
      expect(view._shellIsStub view.model).toBe false

    it 'should return true if shell is a default shell (EmptyShell)', ->
      view = new ShellEditorView viewOptions model: new EmptyShell.Model
      expect(view._shellIsStub view.model).toBe true


  describe 'ShellEditorView::_onThumbnailChange', ->

    it 'should update the _lastThumbnail property', ->
      view = new ShellEditorView viewOptions()
      view._lastThumbnail = 'old thumbnail'
      spyOn(view.model, 'thumbnail').andReturn 'new thumbnail'
      expect(view._lastThumbnail).toBe 'old thumbnail'
      view._onThumbnailChange()
      expect(view._lastThumbnail).toBe 'new thumbnail'

    it 'should announce thumbnail change on itself', ->
      view = new ShellEditorView viewOptions()
      spy = new test.EventSpy view, 'ShellEditor:Thumbnail:Change'
      expect(spy.triggered).toBe false
      view._onThumbnailChange()
      expect(spy.triggered).toBe true

    it 'should announce thumbnail change on eventhub', ->
      view = new ShellEditorView viewOptions()
      spy = new test.EventSpy view.eventhub, 'ShellEditor:Thumbnail:Change'
      expect(spy.triggered).toBe false
      view._onThumbnailChange()
      expect(spy.triggered).toBe true


  describe 'ShellEditorView::_onRemixerSwapShell', ->

    it 'should update model', ->
      oldShell = new acorn.shells.LinkShell.Model
      newShell = new acorn.shells.ImageLinkShell.Model
      view = new ShellEditorView viewOptions model: oldShell
      view.render()

      expect(view.model).toBe oldShell
      remixer = view.remixerViews[0]
      view._onRemixerSwapShell remixer, oldShell, newShell
      expect(view.model).toBe newShell

    it 'should destroy remixerView if model has changed', ->
      oldShell = new acorn.shells.LinkShell.Model
      newShell = new acorn.shells.ImageLinkShell.Model
      view = new ShellEditorView viewOptions model: oldShell
      view.render()

      remixer = view.remixerViews[0]
      spy = spyOn(remixer, 'destroy').andCallThrough()

      expect(spy).not.toHaveBeenCalled()
      view._onRemixerSwapShell remixer, oldShell, newShell
      expect(spy).toHaveBeenCalled()

    it 'should not destroy remixerView if model has not changed', ->
      oldShell = new acorn.shells.LinkShell.Model
      newShell = new acorn.shells.ImageLinkShell.Model
      view = new ShellEditorView viewOptions model: oldShell
      view.render()

      remixer = view.remixerViews[0]
      spy = spyOn(remixer, 'destroy').andCallThrough()

      expect(spy).not.toHaveBeenCalled()
      view._onRemixerSwapShell remixer, oldShell, oldShell
      expect(spy).not.toHaveBeenCalled()

    it 'should create a new remixer if the model has changed', ->
      oldShell = new acorn.shells.LinkShell.Model
      newShell = new acorn.shells.ImageLinkShell.Model
      view = new ShellEditorView viewOptions model: oldShell
      view.render()
      spyOn(view, '_initializeRemixerForShell').andCallThrough()

      expect(view._initializeRemixerForShell).not.toHaveBeenCalled()
      oldRemixer = view.remixerViews[0]
      expect(oldRemixer.model).toBe oldShell

      view._onRemixerSwapShell oldRemixer, oldShell, newShell
      expect(view._initializeRemixerForShell).toHaveBeenCalled()
      expect(view._initializeRemixerForShell).toHaveBeenCalledWith newShell
      newRemixer = view.remixerViews[0]
      expect(newRemixer.model).toBe newShell
      expect(newRemixer).not.toEqual oldRemixer

    it 'should trigger ShellEditor:ShellsUpdated', ->
      oldShell = new acorn.shells.LinkShell.Model
      newShell = new acorn.shells.ImageLinkShell.Model
      view = new ShellEditorView viewOptions model: oldShell
      view.render()
      spy = new test.EventSpy view, 'ShellEditor:ShellsUpdated'

      expect(spy.triggered).toBe false
      remixer = view.remixerViews[0]
      view._onRemixerSwapShell remixer, oldShell, newShell
      expect(spy.triggered).toBe true


  describe 'ShellEditorView::_onRemixerLinkChanged', ->

    it 'should trigger ShellEditor:ShellsUpdated', ->
      view = new ShellEditorView viewOptions()
      view.render()
      spy = new test.EventSpy view, 'ShellEditor:ShellsUpdated'

      expect(spy.triggered).toBe false
      view._onRemixerLinkChanged()
      expect(spy.triggered).toBe true


  describe 'ShellEditorView: Remixer events', ->

    describe 'on Remixer:SwapShell', ->

      it 'should call _onRemixerSwapShell', ->
        spyOn ShellEditorView::, '_onRemixerSwapShell'
        oldShell = new acorn.shells.LinkShell.Model
        newShell = new acorn.shells.ImageLinkShell.Model
        view = new ShellEditorView viewOptions model: oldShell
        spyOn view, '_onRemixerSwapShell'
        view.render()

        changes = ShellEditorView::_onRemixerSwapShell.callCount
        remixer = view.remixerViews[0]
        remixer.trigger 'Remixer:SwapShell', remixer, oldShell, newShell
        expect(ShellEditorView::_onRemixerSwapShell.callCount).toBe changes + 1


    describe 'on Remixer:LinkChanged', ->

      it 'should call _onRemixerLinkChanged', ->
        spyOn ShellEditorView::, '_onRemixerLinkChanged'
        view = new ShellEditorView viewOptions()
        view.render()

        changes = ShellEditorView::_onRemixerLinkChanged.callCount
        view.remixerViews[0].trigger 'Remixer:LinkChanged'
        expect(ShellEditorView::_onRemixerLinkChanged.callCount).toBe changes + 1


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new ShellEditorView viewOptions()
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
