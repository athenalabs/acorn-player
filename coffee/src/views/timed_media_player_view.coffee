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


  onMediaPlay: =>
    if @isInState 'end'
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
    @_elapsedLoops ?= 0

    # advertise progress
    @trigger 'Media:Progress', @, (now - start), (end - start)

    # if current playback is before the start time:
    if now < start and not @_seeking
      # reset loop count in case user has manually restarted
      @_elapsedLoops = 0
      # seek to start
      @seek start
      @_seeking = true

    #  clear seeking flag
    else if start <= now < end
      @_seeking = false

    # if current playback is after the end time, loop or end
    # (avoid incrementing loop count multiple times before restart finishes)
    else if end <= now and not @_seeking
      @_elapsedLoops++

      if @loops() > @_elapsedLoops
        @seek start
        @_seeking = true
      else
        @setMediaState 'end'


  # duration of one loop - get from model
  singleLoopDuration: =>
    @model.singleRunDuration()


  # duration of video given current splicing and looping - get from model
  duration: =>
    @model.duration() or 0
