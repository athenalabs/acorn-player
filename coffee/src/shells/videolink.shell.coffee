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


  properties: => _.extend super,
    timeStart: undefined
    timeEnd: undefined
    timeTotal: undefined


  description: =>
    start = acorn.util.Time.secondsToTimestring @timeStart()
    end = acorn.util.Time.secondsToTimestring @timeEnd()
    "Video #{@link()} from #{start} to #{end}."


  # total possible video time (media length)
  timeTotal: =>
    @timeTotal() ? Infinity


  # duration of one video loop given current splicing
  duration: =>
    end = @timeEnd() ? @timeTotal()
    end - (@timeStart() ? 0)


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


  render: =>
    super

    @$el.empty()

    # TODO: this embedding method primarily does not work
    @$el.append "<embed src='#{@model.get 'link'}'/>"

    # stop ticking, in case we had been playing and this is a re-render.
    @timer.stopTick()
    @


  duration: => @model.duration()


  # executes periodically to adjust video playback.
  onPlaybackTick: =>
    return unless @isPlaying()

    now = @seekOffset()
    start = @model.timeStart() ? 0
    end = @model.timeEnd() ? @model.timeTotal()

    # if current playback is behind the start time, seek to start
    @seek start if now < start

    # if current playback is after the end time, pause or loop. when looping,
    # set `restarting` flag to avoid decrementing the loop count multiple
    # times before the restart has completed
    if now >= end
      return if @restarting

      loops = @model.get 'loops'

      if _.isNumber loops
        @looped ?= 0
        @looped++

      if loops == 'infinity' or (_.isNumber(loops) and loops > @looped)
        @seek start
        @restarting = true
      else
        @pause()
        @eventhub.trigger 'playback:ended'

    else
      @restarting = false



class VideoLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'video-link-shell'


  initialize: =>
    super

    @_timeRangeInputView = new acorn.player.TimeRangeInputView
      start: @model.timeStart()
      end: @model.timeEnd()
      min: 0
      max: @model.timeTotal()

    @_initializeLoopsButton()

    @_timeRangeInputView.on 'change:times', @_onChangeTimes
    @_loopsButtonView.on 'change:value', @_onChangeLoops


  _initializeLoopsButton: =>
    loops = @model.get 'loops'

    # ensure loops property is set
    unless loops?
      loops = 'one'
      @model.set 'loops', loops

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
      buttonName: 'loops:'
      data: loopsButtonData
      initialView: initialView


  render: =>
    super
    @$el.empty()

    @$el.append @_timeRangeInputView.render().el
    @$el.append @_loopsButtonView.render().el

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

    @model.set changes
    @eventhub.trigger 'change:shell', @model, @


  _onChangeLoops: (changed) =>
    loops = if changed.name == 'n' then changed.value else changed.name
    @model.set 'loops', loops



# Register the shell with the acorn object.
acorn.registerShellModule VideoLinkShell
