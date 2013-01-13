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

      describe '\'MediaView:Ready\' event', ->

        it 'should fire after render (waiting for call stack to clear) by
            default', ->
          view = new MediaView viewOptions()
          spy = new EventSpy view, 'MediaView:Ready'

          expect(spy.triggered).toBe false

          runs -> view.render()

          # asynchronous since call stack clears before event is fired
          waitsFor (-> spy.triggered), 'MediaView:Ready event', 100

        it 'should not fire after render when `readyOnInitialize` is false', ->
          MediaView::readyOnInitialize = false
          @after -> MediaView::readyOnInitialize = true

          view = new MediaView viewOptions()
          spy = new EventSpy view, 'MediaView:Ready'

          expect(spy.triggered).toBe false
          tenth = false

          runs ->
            view.render()
            setTimeout (-> tenth = true), 100

          waitsFor (-> tenth), 'tenth of a second', 110

          runs -> expect(spy.triggered).toBe false
