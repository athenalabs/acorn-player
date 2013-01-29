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


  defaults: => _.extend super,
    # video playerView will announce when ready, mediaView forwards event
    readyOnRender: false


  initialize: =>
    super

    @initializeElapsedTimeView()

    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Play', 'Pause', @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()


  initializeElapsedTimeView: =>

    # initialize elapsed time control
    tvModel = new Backbone.Model
      elapsed: 0
      total: @duration() or 0

    @elapsedTimeView = new acorn.player.controls.ElapsedTimeControlView
      eventhub: @eventhub
      model: tvModel

    tvModel.listenTo @playerView, 'Media:Progress', (view, elapsed, total) =>
      tvModel.set 'elapsed', elapsed
      tvModel.set 'total', total


  remove: =>
    @controlsView.off 'PlayControl:Click'
    @controlsView.off 'PauseControl:Click'
    super


  initializeMedia: =>
    # construct player view instead of setting up own media state
    @playerView = new @module.PlayerView
      model: @model
      eventhub: @eventhub
      noControls: true

    @listenTo @playerView, 'all', =>
      # replace @playerView with @
      args = _.map arguments, (arg) =>
        if arg is @playerView then @ else arg

      @trigger.apply @, args

    @on 'Media:StateChange', @togglePlayPauseControls

    @initializeMediaEvents @options



  render: =>
    super
    @$el.empty()
    @$el.append @playerView.render().el
    @togglePlayPauseControls()
    @


  togglePlayPauseControls: =>
    if @isPlaying()
      @controlsView.$('.control-view.play').addClass 'hidden'
      @controlsView.$('.control-view.pause').removeClass 'hidden'
    else
      @controlsView.$('.control-view.play').removeClass 'hidden'
      @controlsView.$('.control-view.pause').addClass 'hidden'


  # forward state transitions
  isInState: (state) => @playerView.isInState(state)


  mediaState: => @playerView.mediaState()
  setMediaState: (state) => @playerView.setMediaState state


  seek: (seconds) => @playerView.seek seconds
  seekOffset: => @playerView.seekOffset() ? 0


  # duration of video given current splicing and looping - get from model
  duration: =>
    @playerView?.duration() or @model.duration() or 0



class VideoLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'video-link-shell'


  template: _.template '''
    <div class='video-player'></div>
    <div class='time-controls'></div>
    '''


  initialize: =>
    super

    @_playerView = new @module.PlayerView
      model: @model
      eventhub: @eventhub
      noControls: true

    @_initializeElapsedTimeView()

    @_controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Play', 'Pause', @_elapsedTimeView]
      eventhub: @eventhub

    @_timeRangeInputView = new acorn.player.TimeRangeInputView
      eventhub: @eventhub
      start: @model.timeStart()
      end: @model.timeEnd()
      min: 0
      max: @model.timeTotal()

    @_initializeLoopsButton()

    @_playerView.on 'Media:StateChange', @_togglePlayPauseControls
    @_playerView.on 'Media:Progress', @_onMediaProgress
    @_controlsView.on 'PlayControl:Click', => @_playerView.play()
    @_controlsView.on 'PauseControl:Click', => @_playerView.pause()
    @_timeRangeInputView.on 'TimeRangeInputView:DidChangeTimes', @_onChangeTimes
    @_timeRangeInputView.on 'TimeRangeInputView:DidChangeProgress',
        @_onChangeProgress
    @_loopsButtonView.on 'CycleButtonView:ValueDidChange', @_onChangeLoops


  _initializeElapsedTimeView: =>

    tvModel = new Backbone.Model
      elapsed: 0
      total: @_duration() or 0

    @_elapsedTimeView = new acorn.player.controls.ElapsedTimeControlView
      eventhub: @eventhub
      model: tvModel

    tvModel.listenTo @_playerView, 'Media:Progress', (view, elapsed, total) =>
      tvModel.set 'elapsed', elapsed
      tvModel.set 'total', total


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
    @$('.time-controls').append @_controlsView.render().el

    @


  # duration of video given current splicing and looping - get from model
  _duration: =>
    @playerView?.duration() or @model.duration() or 0


  _setTimeInputMax: =>
    @_timeRangeInputView.setMax @model.timeTotal()


  _togglePlayPauseControls: =>
    if @_playerView.isPlaying()
      @_controlsView.$('.control-view.play').addClass 'hidden'
      @_controlsView.$('.control-view.pause').removeClass 'hidden'
    else
      @_controlsView.$('.control-view.play').removeClass 'hidden'
      @_controlsView.$('.control-view.pause').addClass 'hidden'


  _onMediaProgress: (view, elapsed, total) =>
    # keep progress bar in sync
    @_progress = @model.timeStart() + elapsed
    @_timeRangeInputView.progress @_progress


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


  _onChangeProgress: (progress) =>
    # if slider progress differs from player progress, seek to new position
    unless progress.toFixed(5) == @_progress?.toFixed(5)
      @_progress = progress
      @_playerView.seek progress


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
