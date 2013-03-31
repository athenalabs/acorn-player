goog.provide 'acorn.specs.player.PlayerView'

goog.require 'acorn.player.PlayerView'

describe 'acorn.player.PlayerView', ->
  PlayerView = acorn.player.PlayerView
  EventSpy = athena.lib.util.test.EventSpy
  derives = athena.lib.util.derives
  Shell = acorn.shells.Shell

  # model for PlayerView contruction
  model = acorn.Model.withData
    acornid: 'thebestacornever'
    thumbnail: acorn.config.img.acorn
    title: 'The Best Title Ever'
    type: 'image'
    shell:
      shellid: 'acorn.Shell'

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(PlayerView).toBeDefined()

  describe 'model verification', ->

    it 'should fail to construct if model was not passed in', ->
      expect(-> new PlayerView).toThrow()

    it 'should fail to construct if model does not define shellModel', ->
      m = model.clone()
      m.set shell: undefined
      expect(-> new PlayerView model: m).toThrow()

    it 'should fail to construct if model type is incorrect', ->
      expect(-> new PlayerView model: new athena.lib.Model).toThrow()
      expect(-> new PlayerView model: new acorn.shells.Shell.Model).toThrow()

    it 'should fail to construct if model does not define valid shellModel', ->
      m = model.clone()
      m.set shell: {shellid: 'foo'}
      expect(-> acorn.shellModuleWithId 'foo').toThrow()
      expect(-> acorn.shellWithAcorn m).toThrow()
      expect(-> new PlayerView model: m).toThrow()

    it 'should succeed to construct if model type is correct', ->
      expect(model instanceof acorn.Model).toBe true
      expect(-> new PlayerView model: model).not.toThrow()

    it 'should succeed to construct if model defines valid shellModel', ->
      shellid = model.attributes.shell.shellid
      expect(-> acorn.shellModuleWithId shellid).not.toThrow()
      expect(-> acorn.shellWithAcorn model).not.toThrow()


  describeView = athena.lib.util.test.describeView
  describeView PlayerView, athena.lib.View, options

  describePlayerSubiew = (name, View, tests) ->

    describe "PlayerView::#{name}", ->

      local = "_#{name}"

      it "#{name} should be a lazyily constructed #{View.name}", ->
        view = new PlayerView model: model, editable: true
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(subview instanceof View).toBe true
        expect(view[local]).toBe subview

      it "#{name} should remain the same once contrsucted", ->
        view = new PlayerView model: model, editable: true
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(view[local]).toBe subview
        expect(view[name]()).toBe subview
        expect(view[name]()).toBe subview

      it "#{name} should be re-constructed if deleted", ->
        view = new PlayerView model: model, editable: true
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(view[local]).toBe subview
        expect(view[name]()).toBe subview

        view[local] = undefined
        expect(view[local]).not.toBeDefined()

        subview2 = view[name]()
        expect(view[local]).toBe subview2
        expect(view[name]()).toBe subview2
        expect(subview).not.toBe subview2

      tests?()


  editorViewTests = ->
    name = 'editorView'
    local = "_#{name}"

    it "#{name} should not be constructed if playerView's `editable` property
        is not truthy", ->
      view = new PlayerView model: model
      view.render()
      expect(view[local]).not.toBeDefined()

      subview = view[name]()
      expect(subview).not.toBeDefined()
      expect(view[local]).not.toBeDefined()

    it "#{name} should pass EditorView player.ShellEditorView if `show:editor`
        passes the option `singleShellEditor: true`", ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()
      expect(view.content() instanceof acorn.player.EditorView).toBe false
      expect(view.$el.attr 'showing').not.toBe 'editor'
      hub.trigger 'show:editor', singleShellEditor: true
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view.$el.attr 'showing').toBe 'editor'
      expect(view.content().options.ShellEditorView)
          .toBe acorn.player.ShellEditorView


  describePlayerSubiew 'editorView', acorn.player.EditorView, editorViewTests
  describePlayerSubiew 'splashView', acorn.player.SplashView
  describePlayerSubiew 'contentView', acorn.player.ContentView


  describe 'events', ->

    it 'should show EditorView on eventhub `show:editor` if editable', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()
      expect(view.content() instanceof acorn.player.EditorView).toBe false
      expect(view.$el.attr 'showing').not.toBe 'editor'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view.$el.attr 'showing').toBe 'editor'

    it 'should not show EditorView on eventhub `show:editor` if uneditable', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      expect(view.content() instanceof acorn.player.EditorView).toBe false
      expect(view.$el.attr 'showing').not.toBe 'editor'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe false
      expect(view.$el.attr 'showing').not.toBe 'editor'

    it 'should show ContentView on eventhub `show:content`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      expect(view.content() instanceof acorn.player.ContentView).toBe false
      expect(view.$el.attr 'showing').not.toBe 'content'
      hub.trigger 'show:content'
      expect(view.content() instanceof acorn.player.ContentView).toBe true
      expect(view.$el.attr 'showing').toBe 'content'

    it 'should show SplashView on eventhub `show:splash`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      hub.trigger 'show:content'
      expect(view.content() instanceof acorn.player.SplashView).toBe false
      expect(view.$el.attr 'showing').not.toBe 'splash'
      hub.trigger 'show:splash'
      expect(view.content() instanceof acorn.player.SplashView).toBe true
      expect(view.$el.attr 'showing').toBe 'splash'

    it 'should send keyups to eventhub', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      _.each athena.lib.util.keys, (key, name) =>
        spy = new EventSpy hub, "Keypress:#{name}"
        event = $.Event 'keydown', {which: key, keyCode: key}
        view.$el.trigger event
        expect(spy.triggered).toBe true


  describe 'editor events (when editable)', ->

    it 'should show contentView on `Editor:Cancel`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()
      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()
      hub.trigger 'Editor:Cancel'
      expect(view.content() instanceof acorn.player.ContentView).toBe true

    it 'should show contentView on `Editor:Saved`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()
      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()
      hub.trigger 'Editor:Saved'
      expect(view.content() instanceof acorn.player.ContentView).toBe true

    it 'should destroy EditorView on `Editor:Cancel`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()

      spy = spyOn(view._editorView, 'destroy').andCallThrough()
      hub.trigger 'Editor:Cancel'
      expect(view._editorView).not.toBeDefined()
      expect(spy).toHaveBeenCalled()

    it 'should destroy EditorView on `Editor:Saved`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()

      spy = spyOn(view._editorView, 'destroy').andCallThrough()
      hub.trigger 'Editor:Saved'
      expect(view._editorView).not.toBeDefined()
      expect(spy).toHaveBeenCalled()

    it 'should destroy and replace existing ContentView on `Editor:Saved`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()

      hub.trigger 'show:content'
      expect(view._contentView).toBeDefined()
      contentView = view._contentView
      spy = spyOn(contentView, 'destroy').andCallThrough()

      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()

      hub.trigger 'Editor:Saved'
      expect(spy).toHaveBeenCalled()
      expect(view._contentView).toBeDefined()
      expect(view._contentView).not.toBe contentView


    it 'should not modify acornModel or shellModel on `Editor:Cancel`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()

      otherAcornId = 'otheracornid '
      otherShellId = 'acorn.LinkShell'

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      acornData = JSON.parse view.model.toJSONString()
      shellData = JSON.parse acorn.shellWithAcorn(view.model).toJSONString()

      editorData =
        acornModel: view._editorView.model
        shellModel: view._editorView.shellEditorView.model

      # make a change to the editor's data
      editorData.acornModel.set 'acornid', otherAcornId
      editorData.shellModel.set 'shellid', otherShellId

      # editor data should be changed
      expect(editorData.acornModel.get 'acornid').toEqual otherAcornId
      expect(editorData.shellModel.get 'shellid').toEqual otherShellId

      # player data should not be changed
      expect(view.model.get 'acornid').not.toEqual otherAcornId
      expect(view.model.shellData().shellid).not.toEqual otherShellId

      hub.trigger 'Editor:Cancel'

      # player data should remain not changed
      expect(view.model.get 'acornid').not.toEqual otherAcornId
      expect(view.model.shellData().shellid).not.toEqual otherShellId
      expect(view.model.attributes).toEqual acornData
      expect(view.model.shellData()).toEqual shellData

    it 'should modify acornModel and shellModel on `Editor:Saved`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub, editable: true
      view.render()

      otherAcornId = 'otheracornid '
      otherShellId = 'acorn.LinkShell'

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      acornData = JSON.parse view.model.toJSONString()
      shellData = JSON.parse acorn.shellWithAcorn(view.model).toJSONString()

      editorData =
        acornModel: view._editorView.model
        shellModel: view._editorView.shellEditorView.model

      # make a change to the editor's data
      editorData.acornModel.set 'acornid', otherAcornId
      editorData.shellModel.set 'shellid', otherShellId

      # editor data should be changed
      expect(editorData.acornModel.get 'acornid').toEqual otherAcornId
      expect(editorData.shellModel.get 'shellid').toEqual otherShellId

      # player data should not be changed
      expect(view.model.get 'acornid').not.toEqual otherAcornId
      expect(view.model.shellData().shellid).not.toEqual otherShellId

      # need to fake the consolidation _editorView.save does
      editorData.acornModel.shellData editorData.shellModel.attributes
      hub.trigger 'Editor:Saved'

      # player data should be changed
      expect(view.model.get 'acornid').toEqual otherAcornId
      expect(view.model.shellData().shellid).toEqual otherShellId
      expect(view.model.attributes).not.toEqual acornData
      expect(view.model.shellData()).not.toEqual shellData


  it 'should allow editable status management through editable method', ->
    view = new PlayerView model: model
    expect(view.editable()).toBeFalsy()
    view.editable true
    expect(view.editable()).toBeTruthy()

    view = new PlayerView model: model, editable: true
    expect(view.editable()).toBeTruthy()
    view.editable false
    expect(view.editable()).toBeFalsy()

  it 'should announce editable status in css', ->
    view = new PlayerView model: model
    expect(view.$el.hasClass 'editable').toBe false
    expect(view.$el.hasClass 'uneditable').toBe true

    view = new PlayerView model: model, editable: true
    expect(view.$el.hasClass 'editable').toBe true
    expect(view.$el.hasClass 'uneditable').toBe false

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a PlayerView into the DOM to see how it looks.
    view = new PlayerView model: model, editable: true
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el

    view.eventhub.trigger 'show:splash'
