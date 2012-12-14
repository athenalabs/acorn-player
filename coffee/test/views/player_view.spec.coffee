goog.provide 'acorn.specs.player.PlayerView'

goog.require 'acorn.player.PlayerView'

describe 'acorn.player.PlayerView', ->
  PlayerView = acorn.player.PlayerView
  EventSpy = athena.lib.util.test.EventSpy
  derives = athena.lib.util.derives

  # model for PlayerView contruction
  model =
    shellModel: new acorn.shells.Shell.Model
    acornModel: acorn.Model.withData
      acornid: 'thebestacornever'
      thumbnail: acorn.config.img.acorn
      title: 'The Best Title Ever'
      type: 'image'

  # emulate shell, object with a ContentView property
  shell = ContentView: athena.lib.View
  model.shellModel.shell = shell

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(PlayerView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView PlayerView, athena.lib.View, options

  describePlayerSubiew = (name, View) ->

    describe "PlayerView::#{name}", ->

      local = "_#{name}"

      it "#{name} should be a lazyily constructed #{View.name}", ->
        view = new PlayerView model: model
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(subview instanceof View).toBe true
        expect(view[local]).toBe subview

      it "#{name} should remain the same once contrsucted", ->
        view = new PlayerView model: model
        view.render()
        expect(view[local]).not.toBeDefined()

        subview = view[name]()
        expect(view[local]).toBe subview
        expect(view[name]()).toBe subview
        expect(view[name]()).toBe subview

      it "#{name} should be re-constructed if deleted", ->
        view = new PlayerView model: model
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

  describePlayerSubiew 'editorView', acorn.player.EditorView
  describePlayerSubiew 'splashView', acorn.player.SplashView
  describePlayerSubiew 'contentView', acorn.player.ContentView


  describe 'events', ->

    it 'should show EditorView on eventhub `show:editor`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      expect(view.content() instanceof acorn.player.EditorView).toBe false
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true

    it 'should show ContentView on eventhub `show:content`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      expect(view.content() instanceof acorn.player.ContentView).toBe false
      hub.trigger 'show:content'
      expect(view.content() instanceof acorn.player.ContentView).toBe true

    it 'should show SplashView on eventhub `show:splash`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      hub.trigger 'show:content'
      expect(view.content() instanceof acorn.player.SplashView).toBe false
      hub.trigger 'show:splash'
      expect(view.content() instanceof acorn.player.SplashView).toBe true


  describe 'editor events', ->

    it 'should show contentView on `Editor:Cancel`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()
      hub.trigger 'Editor:Cancel'
      expect(view.content() instanceof acorn.player.ContentView).toBe true

    it 'should show contentView on `Editor:Save`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()
      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()
      hub.trigger 'Editor:Save'
      expect(view.content() instanceof acorn.player.ContentView).toBe true

    it 'should destroy EditorView on `Editor:Cancel`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()

      spy = spyOn(view._editorView, 'destroy').andCallThrough()
      hub.trigger 'Editor:Cancel'
      expect(view._editorView).not.toBeDefined()
      expect(spy).toHaveBeenCalled()

    it 'should destroy EditorView on `Editor:Save`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()

      spy = spyOn(view._editorView, 'destroy').andCallThrough()
      hub.trigger 'Editor:Save'
      expect(view._editorView).not.toBeDefined()
      expect(spy).toHaveBeenCalled()

    it 'should destroy and replace existing ContentView on `Editor:Save`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()

      hub.trigger 'show:content'
      expect(view._contentView).toBeDefined()
      contentView = view._contentView
      spy = spyOn(contentView, 'destroy').andCallThrough()

      hub.trigger 'show:editor'
      expect(view.content() instanceof acorn.player.EditorView).toBe true
      expect(view._editorView).toBeDefined()

      hub.trigger 'Editor:Save'
      expect(spy).toHaveBeenCalled()
      expect(view._contentView).toBeDefined()
      expect(view._contentView).not.toBe contentView


    it 'should not modify acornModel or shellModel on `Editor:Cancel`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      acornData = JSON.parse view.model.acornModel.toJSONString()
      shellData = JSON.parse view.model.shellModel.toJSONString()

      # make a change to the editor's data
      editorData = view._editorView.model
      editorData.acornModel.set 'acornid', 'otheracornid'
      editorData.shellModel.set 'shellid', 'othershellid'

      # editor data should be changed
      expect(editorData.acornModel.get 'acornid').toEqual 'otheracornid'
      expect(editorData.shellModel.get 'shellid').toEqual 'othershellid'

      # player data should not be changed
      expect(view.model.acornModel.get 'acornid').not.toEqual 'otheracornid'
      expect(view.model.shellModel.get 'shellid').not.toEqual 'othershellid'

      hub.trigger 'Editor:Cancel'

      # player data should remain not changed
      expect(view.model.acornModel.get 'acornid').not.toEqual 'otheracornid'
      expect(view.model.shellModel.get 'shellid').not.toEqual 'othershellid'
      expect(view.model.acornModel.attributes).toEqual acornData
      expect(view.model.shellModel.attributes).toEqual shellData

    it 'should modify acornModel and shellModel on `Editor:Save`', ->
      hub = new athena.lib.View
      view = new PlayerView model: model, eventhub: hub
      view.render()

      hub.trigger 'show:content'
      hub.trigger 'show:editor'
      acornData = JSON.parse view.model.acornModel.toJSONString()
      shellData = JSON.parse view.model.shellModel.toJSONString()

      # make a change to the editor's data
      editorData = view._editorView.model
      editorData.acornModel.set 'acornid', 'otheracornid'
      editorData.shellModel.set 'shellid', 'othershellid'

      # editor data should be changed
      expect(editorData.acornModel.get 'acornid').toEqual 'otheracornid'
      expect(editorData.shellModel.get 'shellid').toEqual 'othershellid'

      # player data should not be changed
      expect(view.model.acornModel.get 'acornid').not.toEqual 'otheracornid'
      expect(view.model.shellModel.get 'shellid').not.toEqual 'othershellid'

      # need to fake the consolidation _editorView.save does
      editorData.acornModel.shellData editorData.shellModel.attributes
      hub.trigger 'Editor:Save'

      # player data should be changed
      expect(view.model.acornModel.get 'acornid').toEqual 'otheracornid'
      expect(view.model.shellModel.get 'shellid').toEqual 'othershellid'
      expect(view.model.acornModel.attributes).not.toEqual acornData
      expect(view.model.shellModel.attributes).not.toEqual shellData


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a PlayerView into the DOM to see how it looks.
    view = new PlayerView model: model
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el

    view.eventhub.trigger 'show:splash'
