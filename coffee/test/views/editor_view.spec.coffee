goog.provide 'acorn.specs.player.EditorView'

goog.require 'acorn.player.EditorView'

describe 'acorn.player.EditorView', ->
  EventSpy = athena.lib.util.test.EventSpy
  EditorView = acorn.player.EditorView
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  # model for EditorView contruction
  model =
    acornModel: new Backbone.Model
      thumbnail: acorn.config.img.acorn
      acornid: 'nyfskeqlyx'
      title: 'The Differential'
    shellModel: new acorn.shells.Shell.Model
      shellid: 'acorn.Shell'

  # patch the models for testing
  model.acornModel.shellData = -> _.clone model.shellModel.attributes
  model.acornModel.save = (attrs, opts) -> opts.error()

  # options for EditorView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(EditorView).toBeDefined()

  describeView EditorView, athena.lib.View, options

  describeSubview
    View: EditorView
    Subview: acorn.player.AcornOptionsView
    subviewAttr: 'acornOptionsView'
    viewOptions: options

  describeSubview
    View: EditorView
    Subview: acorn.player.ShellEditorView
    subviewAttr: 'shellEditorView'
    viewOptions: options

  describeSubview
    View: EditorView
    Subview: athena.lib.ToolbarView
    subviewAttr: 'toolbarView'
    viewOptions: options


  it 'should trigger event `Editor:Cancel` on clicking Cancel', ->
    view = new EditorView options
    spy = new EventSpy view.eventhub, 'Editor:Cancel'
    view.render()
    expect(spy.triggerCount).toBe 0
    view.$('#editor-cancel-btn').trigger 'click'
    expect(spy.triggerCount).toBe 1
    view.$('#editor-cancel-btn').trigger 'click'
    expect(spy.triggerCount).toBe 2

  it 'should call `save` on clicking Save', ->
    view = new EditorView options
    spy = spyOn view, 'save'
    view.render()
    expect(spy).not.toHaveBeenCalled()
    view.$('#editor-save-btn').trigger 'click'
    expect(spy).toHaveBeenCalled()

  describe '.save', ->

    it 'should update acornModel with shellModel attributes', ->
      view = new EditorView options
      spy = spyOn model.acornModel, 'shellData'
      view.render()
      expect(spy).not.toHaveBeenCalled()

      view.save()
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith(model.shellModel.attributes)

    it 'should call save on acornModel', ->
      view = new EditorView options
      spy = spyOn model.acornModel, 'save'
      view.render()
      expect(spy).not.toHaveBeenCalled()

      view.save()
      expect(spy).toHaveBeenCalled()

    it 'should disable `Save` button on calling save', ->
      view = new EditorView options
      spy = spyOn model.acornModel, 'save'

      view.render()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined
      view.save()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe 'disabled'

    it 'should trigger `Editor:Saved` event on save success', ->
      view = new EditorView options

      saveSpy = spyOn model.acornModel, 'save'
      saveSpy.andCallFake (attrs, opts) -> opts.success()
      eventSpy = new EventSpy view.eventhub, 'Editor:Saved'

      expect(saveSpy).not.toHaveBeenCalled()
      expect(eventSpy.triggered).toBe false
      view.render()
      view.save()
      expect(saveSpy).toHaveBeenCalled()
      expect(eventSpy.triggered).toBe true

    it 'should NOT re-enable `Save` button on save success', ->
      view = new EditorView options
      spy = spyOn model.acornModel, 'save'
      spy.andCallFake (attrs, opts) -> opts.success()

      view.render()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined

      view.save()
      expect(spy).toHaveBeenCalled()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe 'disabled'


    it 'should re-enable `Save` button on save error', ->
      view = new EditorView options
      spy = spyOn model.acornModel, 'save'
      spy = spy.andCallFake (attrs, opts) -> opts.error()

      view.render()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined

      view.save()
      expect(spy).toHaveBeenCalled()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new EditorView options
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
