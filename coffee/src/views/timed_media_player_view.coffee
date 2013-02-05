goog.provide 'acorn.player.TimedMediaPlayerView'
goog.require 'acorn.player.MediaPlayerView'


class acorn.player.TimedMediaPlayerView extends acorn.player.MediaPlayerView


  initialize: =>
    super

    @timer = new acorn.util.Timer 100, => @onPlaybackTick()

    @on 'Media:DidPlay', => @timer.startTick() if @rendering
    @on 'Media:DidPause', => @timer.stopTick()
    @on 'Media:DidEnd', => @timer.stopTick()


  render: =>
    super
    # stop ticking, in case we had been playing and this is a re-render.
    @timer.stopTick()
    @


  remove: =>
    @timer.stopTick()
    super


  loops: =>
    loops = @model.loops()
    if loops is 'infinity'
      return Infinity
    parseInt loops, 10


  elapsedLoops: (elapsed) =>
    if elapsed >= 0
      @_elapsedLoops = elapsed

    @_elapsedLoops ?= 0


  onMediaPlay: =>
    if @isInState 'end'
      @elapsedLoops 0
      @seek (@model.timeStart() ? 0)


  # executes periodically to adjust video playback.
  onPlaybackTick: =>
    if @switchingMediaState()
      return

    unless @isPlaying()
      @timer.stopTick()
      return

    now = @seekOffset() ? 0
    start = @model.timeStart() ? 0
    end = @model.timeEnd() ? @model.timeTotal()

    # advertise progress
    @trigger 'Media:Progress', @, (now - start), (end - start)

    # if current playback is before the start time:
    if @_playbackIsBeforeStart(now)
      unless @_seeking
        # reset loop count in case user has manually restarted
        @elapsedLoops 0
        # seek to start
        @seek start
        @_seeking = true

    # if current playback is after the end time, loop or end
    # (avoid incrementing loop count multiple times before restart finishes)
    else if @_playbackIsAfterEnd(now)
      unless @_seeking
        @elapsedLoops @elapsedLoops() + 1

        if @loops() > @elapsedLoops()
          @seek start
          @_seeking = true
        else
          @setMediaState 'end'

    # clear seeking flag if playback is in range
    else
      @_seeking = false


  _playbackIsBeforeStart: (current) =>
    current < @model.timeStart() ? 0


  _playbackIsAfterEnd: (current) =>
    current >= @model.timeEnd() ? @model.timeTotal()


  # duration of one loop - get from model
  singleLoopDuration: =>
    @model.singleRunDuration()


  # duration of video given current splicing and looping - get from model
  duration: =>
    @model.duration() or 0
