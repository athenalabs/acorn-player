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
      describeProperty Shell.Model, 'title'
      describeProperty Shell.Model, 'description'
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

      describe 'RemixView::defaultAttributes', ->

        it 'should be a function', ->
          expect(typeof RemixView::defaultAttributes).toBe 'function'

        it 'should return an object', ->
          view = new RemixView viewOptions()
          expect(typeof view.defaultAttributes()).toBe 'object'

        it 'should default thumbnail to acorn.config.img.acorn', ->
          view = new RemixView viewOptions()
          expect(view.defaultAttributes().thumbnail).toBe acorn.config.img.acorn
          expect(view.model.thumbnail()).toBe acorn.config.img.acorn

        it 'should default title to an empty string', ->
          view = new RemixView viewOptions()
          expect(view.defaultAttributes().title).toBe ''
          expect(view.model.title()).toBe ''

        it 'should default description to an empty string', ->
          view = new RemixView viewOptions()
          expect(view.defaultAttributes().description).toBe ''
          expect(view.model.description()).toBe ''


      describe 'RemixView::_attributeCanBeEmpty', ->

        it 'should be a function', ->
          expect(typeof RemixView::_attributeCanBeEmpty).toBe 'function'

        it 'should return an object', ->
          view = new RemixView viewOptions()
          expect(typeof view._attributeCanBeEmpty()).toBe 'object'

        it 'should allow title to be empty', ->
          view = new RemixView viewOptions()
          expect(view._attributeCanBeEmpty().title).toBe true

        it 'should allow description to be empty', ->
          view = new RemixView viewOptions()
          expect(view._attributeCanBeEmpty().description).toBe true

        it 'should not allow thumbnail to be empty', ->
          view = new RemixView viewOptions()
          expect(view._attributeCanBeEmpty().thumbnail).toBe false


      describe 'RemixView::_updateAttributesWithDefaults', ->

        it 'should be a function', ->
          expect(typeof RemixView::_updateAttributesWithDefaults)
              .toBe 'function'

        it 'should be called on initialize', ->
          spyOn RemixView::, '_updateAttributesWithDefaults'
          expect(RemixView::_updateAttributesWithDefaults).not
              .toHaveBeenCalled()

          view = new RemixView viewOptions()
          expect(RemixView::_updateAttributesWithDefaults).toHaveBeenCalled()

        it 'should remember the previous default attribute values', ->
          view = new RemixView viewOptions()
          spyOn(view, 'defaultAttributes').andReturn thumbnail: 'spyValue'

          expect(view._lastDefaults).not.toEqual thumbnail: 'spyValue'
          view._updateAttributesWithDefaults()
          expect(view._lastDefaults).toEqual thumbnail: 'spyValue'

        it 'should remember the previous default attribute values', ->
          view = new RemixView viewOptions()
          view.model.set('thumbnail', undefined)
          spyOn(view, 'defaultAttributes').andReturn thumbnail: 'spyValue'

          expect(view._lastDefaults).not.toEqual thumbnail: 'spyValue'
          view._updateAttributesWithDefaults()


        describe 'model.thumbnail property', ->

          it 'should be set to defaultAttributes().thumbnail on initialize', ->
            spyOn(RemixView::, 'defaultAttributes').andReturn
                thumbnail: 'spyValue'

            expect(RemixView::defaultAttributes).not.toHaveBeenCalled()
            view = new RemixView viewOptions()

            expect(view.model.thumbnail()).toBe 'spyValue'
            expect(RemixView::defaultAttributes).toHaveBeenCalled()

          it 'should be set when its value is undefined', ->
            view = new RemixView viewOptions()
            view.model.set('thumbnail', undefined)
            spyOn(view, 'defaultAttributes').andReturn thumbnail: 'spyValue'

            expect(view.model.thumbnail()).toBeUndefined()
            expect(view.defaultAttributes).not.toHaveBeenCalled()

            view._updateAttributesWithDefaults()
            expect(view.model.thumbnail()).toBe 'spyValue'
            expect(view.defaultAttributes).toHaveBeenCalled()

          it 'should be set when its value is empty string', ->
            view = new RemixView viewOptions()
            view.model.set('thumbnail', '')
            spyOn(view, 'defaultAttributes').andReturn thumbnail: 'spyValue'

            expect(view.model.thumbnail()).toBe ''
            expect(view.defaultAttributes).not.toHaveBeenCalled()

            view._updateAttributesWithDefaults()
            expect(view.model.thumbnail()).toBe 'spyValue'
            expect(view.defaultAttributes).toHaveBeenCalled()

          it 'should be set when its value is that of _lastDefaults.thumbnail',
              ->
            view = new RemixView viewOptions()
            view.model.set('thumbnail', 'lastDefault')
            view._lastDefaults.thumbnail = 'lastDefault'
            spyOn(view, 'defaultAttributes').andReturn thumbnail: 'spyValue'

            expect(view.model.thumbnail()).toBe 'lastDefault'
            expect(view.defaultAttributes).not.toHaveBeenCalled()

            view._updateAttributesWithDefaults()
            expect(view.model.thumbnail()).toBe 'spyValue'
            expect(view.defaultAttributes).toHaveBeenCalled()
