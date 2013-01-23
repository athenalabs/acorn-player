goog.provide 'acorn.shells.VideoLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.player.TimeRangeInputView'
goog.require 'acorn.player.CycleButtonView'
goog.require 'acorn.player.TimedMediaPlayerView'
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
      loops = parseInt(loops)
      loops = 1 unless loops >= 0
      @singleLoopDuration() * loops



class VideoLinkShell.MediaView extends LinkShell.MediaView


  className: @classNameExtend 'video-link-shell'


  initializeMedia: =>
    # construct player view instead of setting up own media state
    @playerView = new @module.PlayerView
      model: @model
      eventhub: @eventhub

    @listenTo @playerView, 'all', _.bind(@trigger, @)

    @initializeMediaEvents @options



  render: =>
    super
    @$el.empty()
    @$el.append @playerView.render().el
    @


  # forward state transitions
  isInState: (state) => @playerView.isInState(state)


  mediaState: => @playerView.mediaState()
  setMediaState: (state) => @playerView.setMediaState state


  seek: (seconds) => @playerView.seek seconds
  seekOffset: => @playerView.seekOffset() ? 0


  # duration of video given current splicing and looping - get from model
  duration: =>
    @model.duration()


  # video playerView will announce when ready, mediaView forwards event
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

    @


  _setTimeInputMax: =>
    @_timeRangeInputView.setMax @model.timeTotal()


  _onChangeTimes: (changed) =>
    changes = {}
    changes.timeStart = changed.start if _.isNumber changed?.start
    changes.timeEnd = changed.end if _.isNumber changed?.end
    seekOffset = undefined

    # calculate seekOffset before changes take place.
    if changes.timeStart? and changes.timeStart isnt @model.timeStart()
      seekOffset = changes.timeStart
    else if changes.timeEnd? and changes.timeEnd isnt @model.timeEnd()
      seekOffset = changes.timeEnd

    @model.set changes

    # when playing, rewind a bit to see the "end"
    if seekOffset is @model.timeEnd() and @_playerView.isPlaying()
      seekOffset = Math.max(seekOffset - 2, @model.timeStart())

    if seekOffset
      @_playerView.seek seekOffset
      @_playerView.looped = 0

    @eventhub.trigger 'change:shell', @model, @


  _onChangeLoops: (changed) =>
    loops = if changed.name == 'n' then changed.value else changed.name
    @model.loops(loops)

    # restart player loops
    @_playerView.looped = 0
    if @_playerView.isPlaying()
      @_playerView.seek @model.timeStart()



class VideoLinkShell.PlayerView extends acorn.player.TimedMediaPlayerView


  className: @classNameExtend 'video-player-view video-link-shell'



# Register the shell with the acorn object.
acorn.registerShellModule VideoLinkShell
