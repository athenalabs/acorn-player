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
      Infinity
    else if loops is 'one'
      1
    else
      parseInt(loops, 10) ? 1


  elapsedLoops: (elapsed) =>
    @_elapsedLoops ?= 0
    if elapsed >= 0
      @_elapsedLoops = elapsed
    @_elapsedLoops


  onMediaPlay: =>
    super
    if @isInState 'end'
      @elapsedLoops 0


  # executes periodically to adjust video playback.
  onPlaybackTick: =>
    if @switchingMediaState()
      return

    unless @isPlaying()
      @timer.stopTick()
      return

    if @duration() == 0
      @pause()
      return

    now = @_seekOffset() ? 0
    start = @model.timeStart() ? 0
    end = @model.timeEnd() ? @model.timeTotal()

    # advertise progress
    @trigger 'Media:Progress', @, @seekOffset(), @duration()

    # if current playback is before the start time:
    if @_playbackIsBeforeStart(now)
      unless @_seeking
        # reset loop count in case user has manually restarted
        @elapsedLoops 0
        # seek to start
        @_seek start
        @_seeking = true

    # if current playback is after the end time, loop or end
    # (avoid incrementing loop count multiple times before restart finishes)
    else if @_playbackIsAfterEnd(now)
      unless @_seeking
        @elapsedLoops @elapsedLoops() + 1

        if @loops() > @elapsedLoops()
          @_seek start
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
  loopTime: =>
    @model.loopTime()


  # duration of video given current splicing and looping - get from model
  duration: =>
    @loopTime() * @loops()


  # seek offset for the underlying player -- implement this to support seeking
  _seekOffset: => 0
  _seek: (offset) =>


  # seek offset within one loop
  loopSeekOffset: =>
    @_seekOffset() - @model.timeStart()


  loopSeek: (offset) =>
    @_seek offset + @model.timeStart()


  # seek offset (based on loop seek offset)
  seekOffset: =>
    @loopTime() * @elapsedLoops() + @loopSeekOffset()


  seek: (offset) =>
    super

    @elapsedLoops Math.floor(offset / @loopTime())
    @loopSeek(offset % @loopTime())
