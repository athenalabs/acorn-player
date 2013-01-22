goog.provide 'acorn.specs.player.TimedMediaPlayerView'

goog.require 'acorn.player.TimedMediaPlayerView'
goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.util.test'

describe 'acorn.player.TimedMediaPlayerView', ->
  TimedMediaPlayerView = acorn.player.TimedMediaPlayerView
  Timer = acorn.util.Timer
  test = athena.lib.util.test

  Model = acorn.shells.VideoLinkShell.Model
  options = (opts={}) ->
    model: new Model _.extend {timeStart: 20, timeEnd: 23, timeTotal: 3}, opts
    eventhub: _.extend {}, Backbone.Events


  it 'should be part of acorn.player', ->
    expect(TimedMediaPlayerView).toBeDefined()

  test.describeView TimedMediaPlayerView, athena.lib.View, options()

  acorn.util.test.describeMediaInterface TimedMediaPlayerView, options()


  describe 'TimedMediaPlayerView::timer', ->

    it 'should be an instance of acorn.util.Timer', ->
      view = new TimedMediaPlayerView options()
      expect(view.timer instanceof Timer).toBe true

    it 'should be initialized with 100 ms', ->
      view = new TimedMediaPlayerView options()
      expect(view.timer.interval).toBe 100

    it 'should be stopped on render', ->
      view = new TimedMediaPlayerView options()
      spyOn view.timer, 'stopTick'
      view.render()
      expect(view.timer.stopTick).toHaveBeenCalled()

    it 'should be started on Media:DidPlay', ->
      view = new TimedMediaPlayerView options()
      spyOn view.timer, 'startTick'
      view.trigger 'Media:DidPlay'
      expect(view.timer.startTick).toHaveBeenCalled()

    it 'should be stopped on Media:DidPause', ->
      view = new TimedMediaPlayerView options()
      spyOn view.timer, 'stopTick'
      view.trigger 'Media:DidPause'
      expect(view.timer.stopTick).toHaveBeenCalled()

    it 'should be stopped on Media:DidEnd', ->
      view = new TimedMediaPlayerView options()
      spyOn view.timer, 'stopTick'
      view.trigger 'Media:DidEnd'
      expect(view.timer.stopTick).toHaveBeenCalled()

    it 'should call onPlaybackTick every 100ms once started', ->
      view = new TimedMediaPlayerView options()
      view.render()

      spyOn view, 'onPlaybackTick'
      check = (count) -> (-> view.onPlaybackTick.callCount is count)
      view.timer.startTick()

      waitsFor check(1), 'called onPlaybackTick', 101
      waitsFor check(2), 'called onPlaybackTick', 101
      waitsFor check(3), 'called onPlaybackTick', 101
      waitsFor check(4), 'called onPlaybackTick', 101
      runs -> expect(view.onPlaybackTick.callCount).toBe 4


  describe 'TimedMediaPlayerView::loops', ->

    it 'should be a function', ->
      expect(typeof TimedMediaPlayerView::loops).toBe 'function'

    it 'should return Infinity if model.loops is `infinity`', ->
      view = new TimedMediaPlayerView options loops: 'infinity'
      expect(view.loops()).toBe Infinity

    it 'should return parsedInt if model.loops is a number', ->
      _.each [0, 1, 20, 4.5, 100, 10312], (loops) ->
        view = new TimedMediaPlayerView options loops: loops
        expect(view.loops()).toBe parseInt(loops, 10)


  describe 'TimedMediaPlayerView::onPlaybackTick', ->

    it 'should be a function', ->
      expect(typeof TimedMediaPlayerView::onPlaybackTick).toBe 'function'

    it 'should stopTick and return unless isPlaying', ->
      view = new TimedMediaPlayerView options()
      spyOn view, 'isPlaying'
      spyOn view, 'seekOffset'
      spyOn view.timer, 'stopTick'

      view.isPlaying.andReturn false
      view.onPlaybackTick()
      expect(view.seekOffset).not.toHaveBeenCalled()
      expect(view.timer.stopTick.callCount).toBe 1

      view.isPlaying.andReturn true
      view.onPlaybackTick()
      expect(view.seekOffset).toHaveBeenCalled()
      expect(view.timer.stopTick.callCount).toBe 1

    it 'should return unless isPlaying', ->
      view = new TimedMediaPlayerView options()
      spyOn view, 'isPlaying'
      spyOn view, 'seekOffset'

      view.isPlaying.andReturn false
      view.onPlaybackTick()
      expect(view.seekOffset).not.toHaveBeenCalled()

      view.isPlaying.andReturn true
      view.onPlaybackTick()
      expect(view.seekOffset).toHaveBeenCalled()


    it 'should seek to start if offset is before startTime', ->
      view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
      view.setMediaState 'play'
      spyOn view, 'seekOffset'
      spyOn view, 'seek'

      _.each [0, 0.1, 10, 15, 19.9], (offset) ->
        view.seekOffset.andReturn offset
        view.onPlaybackTick()
        expect(view.seek).toHaveBeenCalledWith 20
        expect(view._loopsElapsed).toBe 0
        expect(view.restarting).not.toBeDefined()

    it 'should clear restarting flag if offset is within start and end', ->
      view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
      view.setMediaState 'play'
      spyOn view, 'seekOffset'
      spyOn view, 'seek'

      _.each [20, 20.5, 21, 22, 22.9], (offset) ->
        view.seekOffset.andReturn offset
        view.onPlaybackTick()
        expect(view.seek).not.toHaveBeenCalled()
        expect(view._loopsElapsed).toBe 0
        expect(view.restarting).toBe false

    it 'should increment loopsElapsed if offset is after end', ->
      _.each [23, 23.5, 24, 500], (offset, times) ->
        view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
        view.setMediaState 'play'
        spyOn view, 'seekOffset'
        spyOn view, 'seek'

        view.seekOffset.andReturn offset
        view.onPlaybackTick()
        expect(view._loopsElapsed).toBe 1

    it 'should seek start if offset is after end, and loops remain', ->
      _.each [23, 23.5, 24, 500], (offset) ->
        _.each [100, 50, 2, 1], (loops) ->
          opts = options {timeStart: 20, timeEnd: 23, loops: 100}
          view = new TimedMediaPlayerView opts
          view.setMediaState 'play'
          spyOn view, 'seekOffset'
          spyOn view, 'seek'

          view.seekOffset.andReturn offset
          view.onPlaybackTick()
          expect(view.seek).toHaveBeenCalledWith 20
          expect(view._loopsElapsed).toBe 1
          expect(view.restarting).toBe true

    it 'should end if offset is after end, and no loops remain', ->
      _.each [23, 23.5, 24, 500], (offset) ->
        _.each [100, 50, 2, 1], (loops) ->
          opts = options {timeStart: 20, timeEnd: 23, loops: loops}
          view = new TimedMediaPlayerView opts
          view.setMediaState 'play'
          spyOn view, 'seekOffset'
          spyOn view, 'seek'
          spyOn view, 'setMediaState'

          view.seekOffset.andReturn offset
          view._loopsElapsed = loops - 1
          view.onPlaybackTick()

          expect(view.seek).not.toHaveBeenCalled()
          expect(view._loopsElapsed).toBe loops
          expect(view.restarting).not.toBeDefined()
          expect(view.seek).not.toHaveBeenCalled()
          expect(view.setMediaState.argsForCall[0]).toEqual ['pause']
          expect(view.setMediaState.argsForCall[1]).toEqual ['end']
