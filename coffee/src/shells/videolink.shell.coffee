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
  title: 'Video Link'
  description: 'a video embedded via link'
  icon: 'icon-play'
  validLinkPatterns: [ acorn.util.urlRegEx('.*\.(avi|mov|wmv)') ]



class VideoLinkShell.Model extends LinkShell.Model


  timeTotal: @property 'timeTotal'
  timeStart: @property 'timeStart'
  timeEnd: @property 'timeEnd'
  loops: @property 'loops'


  defaultAttributes: =>
    superDefaults = super

    _.extend superDefaults,
      title: @link()
      description: @_defaultDescription()


  _defaultDescription: =>
    if _.isFinite(@timeStart()) and _.isFinite @timeEnd()
      start = acorn.util.Time.secondsToTimestring @timeStart()
      end = acorn.util.Time.secondsToTimestring @timeEnd()
      clipping = " from #{start} to #{end}"

    "Remix of video \"#{@link()}\"#{clipping ? ''}."


  # duration of one video loop given current splicing
  loopTime: =>
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
      @loopTime() * loops



class VideoLinkShell.MediaView extends LinkShell.MediaView


  className: @classNameExtend 'video-link-shell'


  defaults: => _.extend super,
    # video playerView will announce when ready, mediaView forwards event
    readyOnRender: false


  initialize: =>
    super

    @initializePlayPauseToggleView()
    @initializeElapsedTimeView()

    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: [@playPauseToggleView, @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @seek
    @playerView.on 'Media:Progress', @_updateProgressBar


  initializePlayPauseToggleView: =>
    model = new Backbone.Model
    model.isPlaying = => @isPlaying()

    @playPauseToggleView = new acorn.player.controls.PlayPauseControlToggleView
      eventhub: @eventhub
      model: model


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

    @on 'Media:StateChange', => @playPauseToggleView.refreshToggle()

    @initializeMediaEvents @options


  render: =>
    super
    @$el.empty()
    @$el.append @playerView.render().el
    @playPauseToggleView.refreshToggle()
    @


  _onProgressBarDidProgress: (percentProgress) =>
    @seek @progressFromPercent percentProgress


  # forward state transitions
  isInState: (state) => @playerView.isInState(state)


  mediaState: => @playerView.mediaState()
  setMediaState: (state) => @playerView.setMediaState state


  seek: (seconds) =>
    super
    @playerView.seek seconds


  seekOffset: => @playerView.seekOffset() ? 0


  # duration of video given current splicing and looping - get from model
  duration: =>
    @playerView?.duration() or @model.duration() or 0



class VideoLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'video-link-shell'


  template: _.template '''
    <div class='video-player'></div>
    <div class='time-controls'>
      <div class="time-input"></div>
    </div>
    '''


  initialize: =>
    super

    @initializeRemixMediaView()
    @initializeLoopsButton()
    @initializeTimeRangeView()


  initializeRemixMediaView: =>
    @remixMediaView = new acorn.player.TimedMediaRemixView
      eventhub: @eventhub
      model: @model

    mediaView = @remixMediaView.mediaView
    @listenTo mediaView, 'Media:Progress', (view, elapsed, total) =>
      elapsed += @model.timeStart()
      @timeRangeView.progress elapsed, {silent: true}


  initializeTimeRangeView: =>

    @timeRangeView = new acorn.player.TimeRangeInputView
      eventhub: @eventhub
      start: @model.timeStart()
      end: @model.timeEnd()
      min: 0
      max: @model.timeTotal()

    @timeRangeView.on 'TimeRangeInputView:DidChangeTimes', @onChangeTimes
    @timeRangeView.on 'TimeRangeInputView:DidChangeProgress', @onChangeProgress
    @loopsButtonView.on 'CycleButtonView:ValueDidChange', @onChangeLoops


  initializeLoopsButton: =>
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

    @loopsButtonView = new acorn.player.CycleButtonView
      eventhub: @eventhub
      buttonName: 'loops:'
      data: loopsButtonData
      initialView: initialView
      extraClasses: ['loops-button']


  render: =>
    super
    @$el.empty()

    @$el.append @remixMediaView.render().el

    @remixMediaView.progressBarView.$el.hide()
    @$('.time-controls').first().prepend @timeRangeView.render().el
    @$('.time-controls').first().append @loopsButtonView.render().el
    @


  # called by subclasses
  _setTimeInputMax: =>
    @timeRangeView.setMax @model.timeTotal()


  onChangeTimes: (changed) =>
    changes = {}
    changes.timeStart = changed.start if _.isNumber changed?.start
    changes.timeEnd = changed.end if _.isNumber changed?.end


    # calculate seekOffset before changes take place.
    if changes.timeStart? and changes.timeStart isnt @model.timeStart()
      seekOffset = 0
    else if changes.timeEnd? and changes.timeEnd isnt @model.timeEnd()
      seekOffset = Infinity # will be bounded to duration after changes

    @model.set changes

    # unless user paused the video, make sure it is playing
    unless @remixMediaView.mediaView.isInState 'pause'
      @remixMediaView.mediaView.play()

    if seekOffset?
      # bound between 0 <= seekOffset <= @duration() -2
      seekOffset = Math.max(0, Math.min(seekOffset, @model.duration() - 2))
      @remixMediaView.mediaView.seek seekOffset

    @eventhub.trigger 'change:shell', @model, @


  onChangeProgress: (progress) =>
    # if slider progress differs from player progress, seek to new position
    progress = progress - @model.timeStart()
    @remixMediaView.mediaView.seek progress


  onChangeLoops: (changed) =>
    loops = if changed.name == 'n' then changed.value else changed.name
    @model.loops(loops)

    # restart player loops
    if @remixMediaView.mediaView.isPlaying()
      @remixMediaView.mediaView.seek 0



class VideoLinkShell.PlayerView extends acorn.player.TimedMediaPlayerView


  className: @classNameExtend 'video-player-view video-link-shell'



# Register the shell with the acorn object.
acorn.registerShellModule VideoLinkShell
