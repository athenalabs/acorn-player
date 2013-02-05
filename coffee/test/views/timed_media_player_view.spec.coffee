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
      view.render()
      spyOn view.timer, 'startTick'
      view.trigger 'Media:DidPlay'
      expect(view.timer.startTick).toHaveBeenCalled()

    it 'should be stopped on Media:DidPause', ->
      view = new TimedMediaPlayerView options()
      view.render()
      spyOn view.timer, 'stopTick'
      view.trigger 'Media:DidPause'
      expect(view.timer.stopTick).toHaveBeenCalled()

    it 'should be stopped on Media:DidEnd', ->
      view = new TimedMediaPlayerView options()
      view.render()
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


  describe 'TimedMediaPlayerView::elapsedLoops', ->

    it 'should be a function', ->
      expect(typeof TimedMediaPlayerView::elapsedLoops).toBe 'function'

    it 'should return 0 when media player has not yet played', ->
      view = new TimedMediaPlayerView options()
      expect(view.elapsedLoops()).toBe 0

    it 'should be a getter for elapsed loop count', ->
      view = new TimedMediaPlayerView options()
      _.each [0, 1, 20, 4.5, 100, 10312], (loops) ->
        view._elapsedLoops = loops
        expect(view.elapsedLoops()).toBe loops

    it 'should be a setter for elapsed loop count', ->
      view = new TimedMediaPlayerView options()
      _.each [0, 1, 20, 4.5, 100, 10312], (loops) ->
        view.elapsedLoops loops
        expect(view.elapsedLoops()).toBe loops

    it 'should reset elapsedLoops when playing after being ended', ->
      view = new TimedMediaPlayerView options()
      view.setMediaState 'end'
      view.elapsedLoops 1

      # confirm background expectations
      expect(view.isInState 'end').toBe true
      expect(view.elapsedLoops()).toBe 1

      view.setMediaState 'play'
      expect(view.isInState 'play').toBe true
      expect(view.elapsedLoops()).toBe 0


  describe 'TimedMediaPlayerView::_playbackIsBeforeStart', ->

    it 'should be a function', ->
      expect(typeof TimedMediaPlayerView::_playbackIsBeforeStart)
          .toBe 'function'

    it 'should be true if current time is less than timeStart', ->
      _.each [0, 9, 9.9, 22, 22.9], (offset, times) ->
        view = new TimedMediaPlayerView options {timeStart: 23, timeEnd: 26}
        expect(view._playbackIsBeforeStart(offset)).toBe true

    it 'should be false if current time is at least timeStart', ->
      _.each [23, 23.5, 24, 500], (offset, times) ->
        view = new TimedMediaPlayerView options {timeStart: 23, timeEnd: 26}
        expect(view._playbackIsBeforeStart(offset)).toBe false


  describe 'TimedMediaPlayerView::_playbackIsAfterEnd', ->

    it 'should be a function', ->
      expect(typeof TimedMediaPlayerView::_playbackIsAfterEnd).toBe 'function'

    it 'should be true if current time is equal to or greater than timeEnd', ->
      _.each [23, 23.5, 24, 500], (offset, times) ->
        view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
        expect(view._playbackIsAfterEnd(offset)).toBe true

    it 'should be false if current time is less than timeEnd', ->
      _.each [0, 9, 9.9, 22, 22.9], (offset, times) ->
        view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
        expect(view._playbackIsAfterEnd(offset)).toBe false


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
        expect(view.elapsedLoops()).toBe 0
        expect(view._seeking).toBeDefined()

    it 'should clear _seeking flag if offset is within start and end', ->
      view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
      view.setMediaState 'play'
      spyOn view, 'seekOffset'
      spyOn view, 'seek'

      _.each [20, 20.5, 21, 22, 22.9], (offset) ->
        view.seekOffset.andReturn offset
        view.onPlaybackTick()
        expect(view.seek).not.toHaveBeenCalled()
        expect(view.elapsedLoops()).toBe 0
        expect(view._seeking).toBe false

    it 'should increment elapsedLoops if offset is after end', ->
      _.each [23, 23.5, 24, 500], (offset, times) ->
        view = new TimedMediaPlayerView options {timeStart: 20, timeEnd: 23}
        view.setMediaState 'play'
        spyOn view, 'seekOffset'
        spyOn view, 'seek'

        view.seekOffset.andReturn offset
        view.onPlaybackTick()
        expect(view.elapsedLoops()).toBe 1

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
          expect(view.elapsedLoops()).toBe 1
          expect(view._seeking).toBe true

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
          view.elapsedLoops loops - 1
          view.onPlaybackTick()

          expect(view.seek).not.toHaveBeenCalled()
          expect(view.elapsedLoops()).toBe loops
          expect(view._seeking).not.toBeDefined()
          expect(view.seek).not.toHaveBeenCalled()
          expect(view.setMediaState.argsForCall[0]).toEqual ['end']
