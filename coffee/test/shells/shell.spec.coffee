goog.provide 'acorn.specs.shells.Shell'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.util.test'

describe 'acorn.shells.Shell', ->
  Shell = acorn.shells.Shell

  Model = Shell.Model
  MediaView = Shell.MediaView
  RemixView = Shell.RemixView

  viewOptions = ->
    model: new Model
    eventhub: _.extend {}, Backbone.Events

  EventSpy = athena.lib.util.test.EventSpy

  it 'should be part of acorn.shells', ->
    expect(Shell).toBeDefined()

  acorn.util.test.describeShellModule Shell, ->

    describe 'Shell.Model', ->

      describe 'Model factory constructors', ->

        it 'should correctly construct a model from data', ->
          modelInstance = Shell.Model.withData { shellid: 'acorn.Shell' }
          expect(modelInstance).toBeDefined()
          expect(modelInstance.shellid()).toBe 'acorn.Shell'
          expect(modelInstance.get 'shellid').toBe 'acorn.Shell'

        it 'should correctly set the shellid from module', ->
          modelInstance = new Shell.Model
          expect(modelInstance.shellid()).toBe 'acorn.Shell'

        it 'should throw error on attempts to construct unregistered shells', ->
          fn = -> Shell.Model.withData { shellid: 'foobar' }
          expect(fn).toThrow()


      describeProperty = athena.lib.util.test.describeProperty
      describeProperty Shell.Model, 'shellid', {}, setter: false
      describeProperty Shell.Model, 'title', {}, default: ''
      describeProperty Shell.Model, 'description', {}, default: ''
      describeProperty Shell.Model, 'sources', {}, default: []
      describeProperty Shell.Model, 'thumbnail'


    describe 'Shell.MediaView', ->

      describe '\'Media:Ready\' event', ->

        it 'should fire after render by default (readyOnRender is true)', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'Media:Ready'

          expect(view.options.readyOnRender).toBe true
          expect(spy.triggered).toBe false
          view.render()
          expect(spy.triggered).toBe true

        it 'should not fire after render when `readyOnRender` is false', ->
          view = new MediaView _.extend viewOptions(), readyOnRender: false
          spy = new EventSpy view, 'Media:Ready'

          expect(view.options.readyOnRender).toBe false
          expect(spy.triggered).toBe false
          view.render()
          expect(spy.triggered).toBe false


      describe 'playOnReady', ->

        it 'should by default not play video on Media:Ready', ->
          view = new MediaView viewOptions()
          spyOn view, 'play'

          expect(view.play).not.toHaveBeenCalled()
          view.render()
          expect(view.play).not.toHaveBeenCalled()

        it 'should play video on Media:Ready if passed `playOnReady`', ->
          view = new MediaView _.extend viewOptions(), {playOnReady: true}
          spyOn view, 'play'

          expect(view.play).not.toHaveBeenCalled()
          view.render()
          expect(view.play).toHaveBeenCalled()


    describe 'Shell.RemixView', ->

      describe 'RemixView::defaultThumbnail', ->

        it 'should be a function', ->
          expect(typeof RemixView::defaultThumbnail).toBe 'function'

        it 'should return acorn.config.img.acorn', ->
          view = new RemixView viewOptions()
          expect(view.defaultThumbnail()).toBe acorn.config.img.acorn


      describe 'RemixView::_updateThumbnailWithDefault', ->

        it 'should be a function', ->
          expect(typeof RemixView::_updateThumbnailWithDefault).toBe 'function'

        it 'should be called on initialize', ->
          spyOn RemixView::, '_updateThumbnailWithDefault'
          expect(RemixView::_updateThumbnailWithDefault).not.toHaveBeenCalled()

          view = new RemixView viewOptions()
          expect(RemixView::_updateThumbnailWithDefault).toHaveBeenCalled()

        it 'should set thumbnail property on model to defaultThumbnail on
            initialize', ->
          spyOn(RemixView::, 'defaultThumbnail').andReturn 'spyValue'

          expect(RemixView::defaultThumbnail).not.toHaveBeenCalled()
          view = new RemixView viewOptions()

          expect(view.model.thumbnail()).toBe 'spyValue'
          expect(RemixView::defaultThumbnail).toHaveBeenCalled()

        it 'should remember the previous default thumbnail value', ->
          view = new RemixView viewOptions()
          view.model.set('thumbnail', undefined)
          spyOn(view, 'defaultThumbnail').andReturn 'spyValue'

          expect(view._lastDefaultThumbnail).not.toBe 'spyValue'
          view._updateThumbnailWithDefault()
          expect(view._lastDefaultThumbnail).toBe 'spyValue'

        it 'should set thumbnail property on model when its value is
            undefined', ->
          view = new RemixView viewOptions()
          view.model.set('thumbnail', undefined)
          spyOn(view, 'defaultThumbnail').andReturn 'spyValue'

          expect(view.model.thumbnail()).toBeUndefined()
          expect(view.defaultThumbnail).not.toHaveBeenCalled()

          view._updateThumbnailWithDefault()
          expect(view.model.thumbnail()).toBe 'spyValue'
          expect(view.defaultThumbnail).toHaveBeenCalled()

        it 'should set thumbnail property on model when its value is empty
            string', ->
          view = new RemixView viewOptions()
          view.model.set('thumbnail', '')
          spyOn(view, 'defaultThumbnail').andReturn 'spyValue'

          expect(view.model.thumbnail()).toBe ''
          expect(view.defaultThumbnail).not.toHaveBeenCalled()

          view._updateThumbnailWithDefault()
          expect(view.model.thumbnail()).toBe 'spyValue'
          expect(view.defaultThumbnail).toHaveBeenCalled()

        it 'should set thumbnail property on model when its value is that of
            _lastDefaultThumbnail', ->
          view = new RemixView viewOptions()
          view.model.set('thumbnail', 'lastDefault')
          view._lastDefaultThumbnail = 'lastDefault'
          spyOn(view, 'defaultThumbnail').andReturn 'spyValue'

          expect(view.model.thumbnail()).toBe 'lastDefault'
          expect(view.defaultThumbnail).not.toHaveBeenCalled()

          view._updateThumbnailWithDefault()
          expect(view.model.thumbnail()).toBe 'spyValue'
          expect(view.defaultThumbnail).toHaveBeenCalled()
