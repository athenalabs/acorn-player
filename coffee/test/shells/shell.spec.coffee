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
      describeProperty Shell.Model, 'thumbnail', {},
        default: acorn.config.img.acorn

      describeProperty Shell.Model, 'defaultThumbnail', {},
        default: acorn.config.img.acorn


    describe 'Shell.MediaView', ->

      describe '\'Media:Ready\' event', ->

        it 'should fire after render by default', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'Media:Ready'

          expect(spy.triggered).toBe false
          view.render()
          expect(spy.triggered).toBe true

        it 'should not fire after render when `readyOnRender` is false', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'Media:Ready'

          expect(spy.triggered).toBe false
          view.readyOnRender = false
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
