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
      describeProperty Shell.Model, 'shellid', setter: false
      describeProperty Shell.Model, 'title'
      describeProperty Shell.Model, 'description'
      describeProperty Shell.Model, 'sources', default: []
      describeProperty Shell.Model, 'thumbnail'


      describe 'Model::defaultAttributes', ->

        it 'should be a function', ->
          expect(typeof Model::defaultAttributes).toBe 'function'

        it 'should return an object', ->
          model = new Model
          expect(typeof model.defaultAttributes()).toBe 'object'

        it 'should default thumbnail to acorn.config.img.acorn', ->
          model = new Model
          expect(model.defaultAttributes().thumbnail).toBe acorn.config.img.acorn

        it 'should default title to an empty string', ->
          model = new Model
          expect(model.defaultAttributes().title).toBe ''

        it 'should default description to an empty string', ->
          model = new Model
          expect(model.defaultAttributes().description).toBe ''


      describe 'Model::_updateAttributesWithDefaults', ->

        it 'should be a function', ->
          expect(typeof Model::_updateAttributesWithDefaults).toBe 'function'

        it 'should remember the previous default attribute values', ->
          model = new Model
          spyOn(model, 'defaultAttributes').andReturn thumbnail: 'spyValue'

          expect(model._lastDefaults).not.toEqual thumbnail: 'spyValue'
          model._updateAttributesWithDefaults()
          expect(model._lastDefaults).toEqual thumbnail: 'spyValue'

        it 'should remember the previous default attribute values', ->
          model = new Model
          model.set('thumbnail', undefined)
          spyOn(model, 'defaultAttributes').andReturn thumbnail: 'spyValue'

          expect(model._lastDefaults).not.toEqual thumbnail: 'spyValue'
          model._updateAttributesWithDefaults()


        describe 'setting attributes to defaults', ->

          it 'should happen when an attribute\'s value is undefined', ->
            model = new Model
            model.set('fakeAttr', undefined)
            model.fakeAttr = Model.property 'fakeAttr'
            spyOn(model, 'defaultAttributes').andReturn fakeAttr: 'spyValue'

            expect(model.fakeAttr()).toBeUndefined()
            expect(model.defaultAttributes).not.toHaveBeenCalled()

            model._updateAttributesWithDefaults()
            expect(model.fakeAttr()).toBe 'spyValue'
            expect(model.defaultAttributes).toHaveBeenCalled()

          it 'should happen when an attribute\'s value is empty string', ->
            model = new Model
            model.set('fakeAttr', '')
            model.fakeAttr = Model.property 'fakeAttr'
            spyOn(model, 'defaultAttributes').andReturn fakeAttr: 'spyValue'

            expect(model.fakeAttr()).toBe ''
            expect(model.defaultAttributes).not.toHaveBeenCalled()

            model._updateAttributesWithDefaults()
            expect(model.fakeAttr()).toBe 'spyValue'
            expect(model.defaultAttributes).toHaveBeenCalled()

          it 'should happen when an attribute\'s value matches that of
              _lastDefaults', ->
            model = new Model
            model.set('fakeAttr', 'lastDefault')
            model.fakeAttr = Model.property 'fakeAttr'
            model._lastDefaults = fakeAttr: 'lastDefault'
            spyOn(model, 'defaultAttributes').andReturn fakeAttr: 'spyValue'

            expect(model.fakeAttr()).toBe 'lastDefault'
            expect(model.defaultAttributes).not.toHaveBeenCalled()

            model._updateAttributesWithDefaults()
            expect(model.fakeAttr()).toBe 'spyValue'
            expect(model.defaultAttributes).toHaveBeenCalled()


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


      describe 'MediaView::percentProgress', ->

        it 'should be a function', ->
          expect(typeof MediaView::percentProgress).toBe 'function'

        it 'should return the progress of total duration as a percent', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 80
          spyOn view, 'seekOffset'

          view.seekOffset.andReturn 0
          expect(view.percentProgress()).toBe 0

          view.seekOffset.andReturn 20
          expect(view.percentProgress()).toBe 25

          view.seekOffset.andReturn 40
          expect(view.percentProgress()).toBe 50

          view.seekOffset.andReturn 60
          expect(view.percentProgress()).toBe 75

          view.seekOffset.andReturn 80
          expect(view.percentProgress()).toBe 100


      describe 'MediaView::progressFromPercent', ->

        it 'should be a function', ->
          expect(typeof MediaView::progressFromPercent).toBe 'function'

        it 'should return the progress that corresponds to a given percent of
            total duration', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 80

          expect(view.progressFromPercent 0).toBe 0
          expect(view.progressFromPercent 25).toBe 20
          expect(view.progressFromPercent 50).toBe 40
          expect(view.progressFromPercent 75).toBe 60
          expect(view.progressFromPercent 100).toBe 80


      describe 'MediaView::progressBarState', ->

        it 'should be a function', ->
          expect(typeof MediaView::progressBarState).toBe 'function'

        it 'should return an object with showing and progress properties', ->
          view = new MediaView viewOptions()
          state = view.progressBarState()
          expect(state.showing).toBeDefined()
          expect(state.progress).toBeDefined()

        it 'should return an object with showing: false when duration is
            Infinity', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn Infinity

          expect(view.progressBarState().showing).toBe false

        it 'should return an object with showing: true when duration is not
            Infinity', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 50

          expect(view.progressBarState().showing).toBe true

        it 'should return an object with progress set to percentProgress when
            duration is not Infinity', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 50
          spyOn(view, 'percentProgress').andReturn 'fakeValue'

          expect(view.progressBarState().progress).toBe 'fakeValue'


      describe 'MediaView::_updateProgressBar', ->

        it 'should be a function', ->
          expect(typeof MediaView::_updateProgressBar).toBe 'function'

        it 'should trigger "Shell:UpdateProgressBar" event', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'Shell:UpdateProgressBar'

          expect(spy.triggered).toBe false
          view._updateProgressBar()
          expect(spy.triggered).toBe true

        it 'should trigger "Shell:UpdateProgressBar" event with showing and
            progress values', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'Shell:UpdateProgressBar'
          spyOn(view, 'progressBarState').andReturn
            showing: 'fakeShowing'
            progress: 'fakeProgress'

          expect(spy.triggered).toBe false
          view._updateProgressBar()
          expect(spy.triggered).toBe true
          expect(spy.arguments[0][0]).toBe 'fakeShowing'
          expect(spy.arguments[0][1]).toBe 'fakeProgress'


      describe 'MediaView::_onProgressBarDidProgress', ->

        it 'should be a function', ->
          expect(typeof MediaView::_onProgressBarDidProgress).toBe 'function'

        it 'should be called to handle a "ProgressBar:DidProgress" event', ->
          spyOn MediaView::, '_onProgressBarDidProgress'
          view = new MediaView viewOptions()

          expect(MediaView::_onProgressBarDidProgress).not.toHaveBeenCalled()
          view.trigger 'ProgressBar:DidProgress'
          expect(MediaView::_onProgressBarDidProgress).toHaveBeenCalled()


    describe 'Shell.RemixView', ->

      it 'should not have an active link input', ->
        expect(Shell.RemixView.activeLinkInput).toBe false

      it 'should call model._updateAttributesWithDefaults on initialize', ->
        spyOn Model::, '_updateAttributesWithDefaults'
        expect(Model::_updateAttributesWithDefaults).not
            .toHaveBeenCalled()

        view = new RemixView viewOptions()
        expect(Model::_updateAttributesWithDefaults).toHaveBeenCalled()
