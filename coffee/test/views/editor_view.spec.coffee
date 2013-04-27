goog.provide 'acorn.specs.player.EditorView'

goog.require 'acorn.player.EditorView'

describe 'acorn.player.EditorView', ->
  Shell = acorn.shells.Shell
  TextShell = acorn.shells.TextShell
  EventSpy = athena.lib.util.test.EventSpy
  EditorView = acorn.player.EditorView
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  # model for EditorView contruction
  model = new acorn.Model
    thumbnail: acorn.config.img.acorn
    acornid: 'nyfskeqlyx'
    title: 'The Differential'
    shell: (new TextShell.Model).toJSON()


  # patch the model for testing
  model.save = (attrs, opts) -> opts.error()

  # options for EditorView contruction
  viewOptions = -> model: model


  it 'should be part of acorn.player', ->
    expect(EditorView).toBeDefined()

  describe 'model verification', ->

    it 'should fail to construct if model was not passed in', ->
      expect(-> new EditorView).toThrow()

    it 'should fail to construct if model type is incorrect', ->
      expect(-> new EditorView model: new athena.lib.Model).toThrow()
      expect(-> new EditorView model: new Shell.Model).toThrow()

    it 'should succeed to construct if model type is correct', ->
      expect(model instanceof acorn.Model).toBe true
      expect(-> new EditorView model: model).not.toThrow()

  describeView EditorView, athena.lib.View, viewOptions()

  describeSubview
    View: EditorView
    Subview: acorn.player.ShellEditorView
    subviewAttr: 'shellEditorView'
    viewOptions: viewOptions()

  describeSubview
    View: EditorView
    Subview: athena.lib.ToolbarView
    subviewAttr: 'toolbarView'
    viewOptions: viewOptions()


  it 'should trigger event `Editor:Cancel` on clicking Cancel', ->
    view = new EditorView viewOptions()
    spy = new EventSpy view.eventhub, 'Editor:Cancel'
    view.render()
    expect(spy.triggerCount).toBe 0
    view.$('#editor-cancel-btn').trigger 'click'
    expect(spy.triggerCount).toBe 1
    view.$('#editor-cancel-btn').trigger 'click'
    expect(spy.triggerCount).toBe 2

  it 'should call `save` on clicking Save', ->
    view = new EditorView viewOptions()
    spy = spyOn view, 'save'
    view.render()
    expect(spy).not.toHaveBeenCalled()
    view.$('#editor-save-btn').trigger 'click'
    expect(spy).toHaveBeenCalled()


  describe '.save', ->

    it 'should update acornModel with shellModel attributes', ->
      view = new EditorView viewOptions()
      spy = spyOn model, 'shellData'
      view.render()
      expect(spy).not.toHaveBeenCalled()

      view.save()
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith(view.shellEditorView.shell().attributes)

    it 'should call save on acornModel', ->
      view = new EditorView viewOptions()
      spy = spyOn model, 'save'
      view.render()
      expect(spy).not.toHaveBeenCalled()

      view.save()
      expect(spy).toHaveBeenCalled()

    it 'should disable `Save` button on calling save', ->
      view = new EditorView viewOptions()
      spy = spyOn model, 'save'

      view.render()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined
      view.save()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe 'disabled'

    it 'should trigger `Editor:Saved` event on save success', ->
      view = new EditorView viewOptions()

      saveSpy = spyOn model, 'save'
      saveSpy.andCallFake (attrs, opts) -> opts.success()
      eventSpy = new EventSpy view.eventhub, 'Editor:Saved'

      expect(saveSpy).not.toHaveBeenCalled()
      expect(eventSpy.triggered).toBe false
      view.render()
      view.save()
      expect(saveSpy).toHaveBeenCalled()
      expect(eventSpy.triggered).toBe true

    it 'should NOT re-enable `Save` button on save success', ->
      view = new EditorView viewOptions()
      spy = spyOn model, 'save'
      spy.andCallFake (attrs, opts) -> opts.success()

      view.render()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined

      view.save()
      expect(spy).toHaveBeenCalled()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe 'disabled'


    it 'should re-enable `Save` button on save error', ->
      view = new EditorView viewOptions()
      spy = spyOn model, 'save'
      spy = spy.andCallFake (attrs, opts) -> opts.error()

      view.render()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined

      view.save()
      expect(spy).toHaveBeenCalled()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe undefined

    it 'should exit immediately if view cannot be saved', ->
      view = new EditorView viewOptions()
      view.render()
      spyOn(view, 'canBeSaved').andReturn false
      spyOn model, 'save'

      expect(view.canBeSaved).not.toHaveBeenCalled()
      expect(model.save).not.toHaveBeenCalled()

      view.save()
      expect(view.canBeSaved).toHaveBeenCalled()
      expect(model.save).not.toHaveBeenCalled()


  describe 'EditorView::_updateSaveButton', ->

    it 'should be a function', ->
      view = new EditorView viewOptions()
      expect(typeof view._updateSaveButton).toBe 'function'

    it 'should listen to shell editor view for shell updates', ->
      view = new EditorView viewOptions()
      spyOn view, '_updateSaveButton'

      expect(view._updateSaveButton).not.toHaveBeenCalled()
      view.render()
      expect(view._updateSaveButton).toHaveBeenCalled()

    it 'should listen to shell editor view for shell updates', ->
      spy = spyOn EditorView::, '_updateSaveButton'
      view = new EditorView viewOptions()
      view.render()

      initialCallCount = spy.callCount
      view.shellEditorView.trigger 'ShellEditor:ShellsUpdated'
      expect(spy.callCount).toBe initialCallCount + 1

    it 'should check whether shell can be saved', ->
      view = new EditorView viewOptions()
      view.render()
      spyOn view, 'canBeSaved'

      expect(view.canBeSaved).not.toHaveBeenCalled()
      view._updateSaveButton()
      expect(view.canBeSaved).toHaveBeenCalled()

    it 'should disable save button if acorn cannot currently be saved', ->
      view = new EditorView viewOptions()
      view.render()
      spyOn(view, 'canBeSaved').andReturn false

      expect(view.$('#editor-save-btn').attr 'disabled').toBeUndefined()
      view._updateSaveButton()
      expect(view.$('#editor-save-btn').attr 'disabled').toBe 'disabled'

    it 'should enable save button if acorn can currently be saved', ->
      view = new EditorView viewOptions()
      view.render()
      spyOn(view, 'canBeSaved').andReturn true

      view.$('#editor-save-btn').attr 'disabled', 'disabled'
      expect(view.$('#editor-save-btn').attr 'disabled').toBe 'disabled'
      view._updateSaveButton()
      expect(view.$('#editor-save-btn').attr 'disabled').toBeUndefined()


  describe 'EditorView::canBeSaved', ->

    it 'should be a function', ->
      view = new EditorView viewOptions()
      expect(typeof view.canBeSaved).toBe 'function'

    it 'should return true if model is not new', ->
      # saved, empty model
      model = new acorn.Model
        acornid: 'nyfskeqlyx'
        shell: (new EmptyShell.Model).toJSON()

      view = new EditorView model: model
      expect(view.canBeSaved()).toBe true

    it 'should return true if model is not empty', ->
      # new, non-empty model
      model = new acorn.Model
        thumbnail: acorn.config.img.acorn
        acornid: 'new'
        title: 'The Differential'
        shell: (new TextShell.Model).toJSON()

      view = new EditorView model: model
      expect(view.canBeSaved()).toBe true

    it 'should return false if model is new and empty', ->
      # new, empty model
      model = new acorn.Model
        acornid: 'new'
        shell: (new EmptyShell.Model).toJSON()

      view = new EditorView model: model
      expect(view.canBeSaved()).toBe false


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new EditorView viewOptions()
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
