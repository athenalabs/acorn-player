goog.provide 'acorn.shells.VideoLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.player.TimeRangeInputView'
goog.require 'acorn.player.CycleButtonView'
goog.require 'acorn.errors'
goog.require 'acorn.util'



LinkShell = acorn.shells.LinkShell
VideoLinkShell = acorn.shells.VideoLinkShell =

  id: 'acorn.VideoLinkShell'
  title: 'VideoLinkShell'
  description: 'A shell for video links.'
  icon: 'icon-play'
  validLinkPatterns: [ acorn.util.urlRegEx('.*\.(avi|mov|wmv)') ]



class VideoLinkShell.Model extends LinkShell.Model


  timeStart: @property 'timeStart'
  timeEnd: @property 'timeEnd'
  loops: @property 'loops'


  title: =>
    super or @link()


  description: =>
    desc = super
    unless desc
      start = acorn.util.Time.secondsToTimestring @timeStart()
      end = acorn.util.Time.secondsToTimestring @timeEnd()
      desc = "Video #{@link()} from #{start} to #{end}."
    desc


  # duration of one video loop given current splicing
  singleLoopDuration: =>
    end = @timeEnd() ? @timeTotal()
    end - (@timeStart() ? 0)


  # duration of video given current splicing and looping
  duration: =>
    loops = @loops()

    if loops == 'infinity'
      Infinity
    else
      if parseInt(loops) >= 0
        loops = parseInt loops
      else
        loops = 1
      @singleLoopDuration() * loops


  # if metaDataUrl is set, returns a resource to sync and cache custom data
  metaData: =>
    if @metaDataUrl() and not @_metaData
      @_metaData = new athena.lib.util.RemoteResource
        url: @metaDataUrl()
        dataType: 'json'

    @_metaData


  # override with resource URL
  metaDataUrl: => ''



class VideoLinkShell.MediaView extends LinkShell.MediaView


  className: @classNameExtend 'video-link-shell'


  initialize: =>
    super

    @timer = new acorn.util.Timer 200, @onPlaybackTick

    @playerView = new @module.PlayerView
      model: @model
      eventhub: @eventhub

    @listenTo @playerView, 'PlayerView:StateChange', @onPlayerViewStateChange
    @listenTo @playerView, 'PlayerView:Ready', @onPlayerViewReady


  render: =>
    # reset ready flag
    @ready = false

    super

    @$el.empty()

    # stop ticking, in case we had been playing and this is a re-render.
    @timer.stopTick()

    @$el.append @playerView.render().el

    @


  # executes periodically to adjust video playback.
  onPlaybackTick: =>
    return unless @isPlaying()

    now = @seekOffset()
    start = @model.timeStart() ? 0
    end = @model.timeEnd() ? @model.timeTotal()

    # if current playback is before the start time:
    if now < start
      # reset loop count in case user has manually restarted
      @looped = 0
      # seek to start
      @seek start

    # if current playback is after the end time, pause or loop
    if now >= end

      # avoid decrementing the loop count multiple times before restart finishes
      return if @restarting

      loops = @model.loops()

      # if loops is a number, count video loops
      if parseInt(loops) >= 0
        loops = parseInt loops
        @looped ?= 0
        @looped++

      if loops == 'infinity' or (_.isNumber(loops) and loops > @looped)
        @seek start
        @restarting = true
      else
        @pause()
        @eventhub.trigger 'playback:ended'

    # otherwise clear restarting flag
    else
      @restarting = false


  onPlayerViewStateChange: =>
    if @isPlaying() then @timer.startTick() else @timer.stopTick()


  onPlayerViewReady: =>
    @ready = true

    # announce ready state if already rendering
    if @rendering
      @trigger 'MediaView:Ready'


  # actions

  play: =>
    @playerView.play()


  pause: =>
    @playerView.pause()


  seek: (seconds) =>
    @playerView.seek seconds


  # state getters

  isPlaying: =>
    @playerView.isPlaying() ? false


  seekOffset: =>
    @playerView.seekOffset() ? 0


  # duration of one video loop given current splicing - get from model
  singleLoopDuration: =>
    @model.singleRunDuration()


  # duration of video given current splicing and looping - get from model
  duration: =>
    @model.duration()


  # video playerView will announce when it is ready, and mediaView will forward
  # the event
  readyOnRender: false



class VideoLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'video-link-shell'


  template: _.template '''
    <div class='video-player'></div>
    <div class='time-controls'></div>
    '''


  initialize: =>
    super

    @_timeRangeInputView = new acorn.player.TimeRangeInputView
      eventhub: @eventhub
      start: @model.timeStart()
      end: @model.timeEnd()
      min: 0
      max: @model.timeTotal()

    @_initializeLoopsButton()

    @_playerView = new @module.PlayerView
      model: @model
      eventhub: @eventhub
      noControls: true

    @_timeRangeInputView.on 'change:times', @_onChangeTimes
    @_loopsButtonView.on 'change:value', @_onChangeLoops


  _initializeLoopsButton: =>
    loops = @model.loops()

    # ensure loops property is set
    unless loops?
      loops = 'one'
      @model.loops(loops)

    # determine initial view index for cycle button
    initialView = switch loops
      when 'one' then 0
      when 'infinity' then 1
      else 2

    # special parameters for n-loops input button
    nLoops =
      value: if initialView == 2 then loops else 2
      validate: (input) ->
        # avoid parseInt since that will round -0.2 to 0
        n = Math.floor parseFloat input
        if n >= 0 then n else undefined

    loopsButtonData = [
      {type: 'static', name: 'one', value: '1'}
      {type: 'static', name: 'infinity', value: '∞'}
      {type: 'input', name: 'n', value: nLoops.value, validate: nLoops.validate}
    ]

    @_loopsButtonView = new acorn.player.CycleButtonView
      eventhub: @eventhub
      buttonName: 'loops:'
      data: loopsButtonData
      initialView: initialView
      extraClasses: ['loops-button']


  render: =>
    super
    @$el.empty()

    @$el.append @template()
    @$('.video-player').append @_playerView.render().el
    @$('.time-controls').append @_timeRangeInputView.render().el
    @$('.time-controls').append @_loopsButtonView.render().el

    # if meta data is waiting, fetch it and reset time input maximum values on
    # retrieval
    @model.metaData()?.sync success: => @_setTimeInputMax()

    @


  _setTimeInputMax: =>
    @_timeRangeInputView.setMax @model.timeTotal()


  _onChangeTimes: (changed) =>
    changes = {}
    changes.timeStart = changed.start if _.isNumber changed?.start
    changes.timeEnd = changed.end if _.isNumber changed?.end

    if changes.timeStart? and changes.timeStart isnt @model.timeStart()
      @_playerView.seek changes.timeStart
    else if changes.timeEnd? and changes.timeEnd isnt @model.timeEnd()
      @_playerView.seek changes.timeEnd

    @model.set changes
    @eventhub.trigger 'change:shell', @model, @


  _onChangeLoops: (changed) =>
    loops = if changed.name == 'n' then changed.value else changed.name
    @model.loops(loops)



class VideoLinkShell.PlayerView extends athena.lib.View


  className: 'video-player-view video-link-shell'


  render: =>
    super
    @$el.empty()

    # TODO: this embedding method primarily does not work
    @$el.append "<embed src='#{@model.get 'link'}'/>"

    @


  # actions - override in child classes

  play: =>


  pause: =>


  seek: (seconds) =>


  # state getters - override in child classes

  isPlaying: => false


  seekOffset: => 0



# Register the shell with the acorn object.
acorn.registerShellModule VideoLinkShell
