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

        it 'should be called after call stack clears following a call to
            render', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'Shell:UpdateProgressBar'

          expect(spy.triggered).toBe false

          view.render()
          setTimeout (-> expect(spy.triggered).toBe true), 0


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
