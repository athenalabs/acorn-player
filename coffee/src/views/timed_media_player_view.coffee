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


  # executes periodically to adjust video playback.
  onPlaybackTick: =>
    unless @isPlaying()
      @timer.stopTick()
      return

    now = @seekOffset()
    start = @model.timeStart() ? 0
    end = @model.timeEnd() ? @model.timeTotal()
    @_loopsElapsed ?= 0

    # if current playback is before the start time:
    if now < start
      # reset loop count in case user has manually restarted
      @_loopsElapsed = 0
      # seek to start
      @seek start

    #  clear restarting flag
    else if start <= now < end
      @restarting = false

    # if current playback is after the end time, loop or end
    # (avoid incrementing loop count multiple times before restart finishes)
    else if end <= now and not @restarting
      @_loopsElapsed++

      if @loops() > @_loopsElapsed
        @seek start
        @restarting = true
      else
        @pause()
        @setMediaState 'end'


  # duration of one loop - get from model
  singleLoopDuration: =>
    @model.singleRunDuration()


  # duration of video given current splicing and looping - get from model
  duration: =>
    @model.duration()
