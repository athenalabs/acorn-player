goog.provide 'acorn.shells.HighlightsShell'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.player.HighlightsSliderView'
goog.require 'acorn.player.ClipSelectView'
goog.require 'acorn.errors'
goog.require 'acorn.util'


Shell = acorn.shells.Shell
HighlightsShell = acorn.shells.HighlightsShell =

  id: 'acorn.HighlightsShell'
  title: 'Highlights'
  description: 'selected parts from media'
  icon: 'icon-cut'



class HighlightsShell.Model extends Shell.Model


  # subshell to wrap
  shell: @property 'shell'


  # set of highlights. These have:
  #   timeStart
  #   timeEnd
  #   title
  highlights: @property('highlights', default: [])


  defaultAttributes: => _.extend super,
    title: @shellModel().title()
    description: @shellModel().description()


  shellModel: =>
    @_shellModel ?= new Shell.Model.withData @shell()


  duration: =>
    @shellModel().duration()



class HighlightsShell.MediaView extends Shell.MediaView


  className: @classNameExtend 'highlights-shell'


  defaults: => _.extend super,
    # subshell will announce when ready, forward event
    readyOnRender: false


  initialize: =>
    super

    @initializePlayPauseToggleView()
    @initializeElapsedTimeView()
    @initializeProgressBarView()

    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: [@playPauseToggleView, @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @seek
    # @subMediaView.on 'Media:Progress', @_updateProgressBar


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

    tvModel.listenTo @subMediaView, 'Media:Progress', (view, elapsed, total) =>
      tvModel.set 'elapsed', elapsed
      tvModel.set 'total', total


  initializeProgressBarView: =>

    @highlightViews = _.map @model.highlights(), (highlight) =>
      clipView = new acorn.player.ClipView
        eventhub: @eventhub
        model: highlight
        min: 0
        max: @model.duration()

      clipView.on 'Clip:Click', (clipView) =>
        @seek clipView.model.timeStart

      clipView

    @progressBarView = new acorn.player.HighlightsSliderView
      extraClasses: ['progress-bar-view']
      eventhub: @eventhub
      value: 0
      highlights: @highlightViews


  remove: =>
    @controlsView.off 'PlayControl:Click'
    @controlsView.off 'PauseControl:Click'
    super


  initializeMedia: =>
    # construct subshell media view
    @subMediaView = new (@model.shellModel()).module.MediaView
      model: @model.shellModel()
      eventhub: @eventhub
      playOnReady: @options.playOnReady

    @listenTo @subMediaView, 'all', =>
      # replace @subMediaView with @
      args = _.map arguments, (arg) =>
        if arg is @subMediaView then @ else arg

      @trigger.apply @, args

    @on 'Media:StateChange', => @playPauseToggleView.refreshToggle()

    @initializeMediaEvents @options


  render: =>
    super
    @$el.empty()
    @$el.append @subMediaView.render().el
    @playPauseToggleView.refreshToggle()
    @


  _onProgressBarDidProgress: (percentProgress) =>
    progress = @progressFromPercent percentProgress

    # if slider progress differs from subshell progress, seek to new position
    unless progress.toFixed(5) == @seekOffset().toFixed(5)
      @seek progress


  # forward state transitions
  isInState: (state) => @subMediaView.isInState(state)


  mediaState: => @subMediaView.mediaState()
  setMediaState: (state) => @subMediaView.setMediaState state


  seek: (seconds) =>
    super
    @subMediaView?.seek seconds


  seekOffset: =>
    @subMediaView?.seekOffset() ? 0


  # duration of video given current splicing and looping - get from model
  duration: =>
    @subMediaView?.duration() or @model.duration() or 0



class HighlightsShell.RemixView extends Shell.RemixView


  className: @classNameExtend 'highlights-shell'


  template: _.template '''
    <div class='media-view'></div>
    <div class='time-controls'></div>
    '''


  initialize: =>
    super
    @initializeSubMediaView()
    @initializePlayPauseToggleView()
    @initializeElapsedTimeView()
    @initializeControls()
    @initializeHighlightsSlider()

  initializeSubMediaView: =>
    @subMediaView = new (@model.shellModel()).module.MediaView
      model: @model.shellModel()
      eventhub: @eventhub
      playOnReady: @options.playOnReady

    @listenTo @subMediaView, 'all', =>
      # replace @subMediaView with @
      args = _.map arguments, (arg) =>
        if arg is @subMediaView then @ else arg

      @trigger.apply @, args

    @subMediaView.on 'Media:StateChange', =>
      @playPauseToggleView.refreshToggle()

    @subMediaView.on 'Media:Progress', =>
      @onMediaProgress()



  initializeControls: =>
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: [@playPauseToggleView, @elapsedTimeView]
      eventhub: @eventhub

    # @clipSelectView = new acorn.player.ClipSelectView
    #   eventhub: @eventhub
    #   start: @model.timeStart()
    #   end: @model.timeEnd()
    #   min: 0
    #   max: @model.timeTotal()

    @timeRangeInputView = @clipSelectView.inputView


    @controlsView.on 'PlayControl:Click', => @subMediaView.play()
    @controlsView.on 'PauseControl:Click', => @subMediaView.pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @subMediaView.seek

    @timeRangeInputView.on 'TimeRangeInputView:DidChangeTimes', @_onChangeTimes
    @timeRangeInputView.on 'TimeRangeInputView:DidChangeProgress',
        @_onChangeProgress


  initializePlayPauseToggleView: =>
    model = new Backbone.Model
    model.isPlaying = => @subMediaView.isPlaying()

    @playPauseToggleView = new acorn.player.controls.PlayPauseControlToggleView
      eventhub: @eventhub
      model: model


  initializeElapsedTimeView: =>

    tvModel = new Backbone.Model
      elapsed: 0
      total: @duration() or 0

    @elapsedTimeView = new acorn.player.controls.ElapsedTimeControlView
      eventhub: @eventhub
      model: tvModel

    tvModel.listenTo @subMediaView, 'Media:Progress', (view, elapsed, total) =>
      tvModel.set 'elapsed', elapsed
      tvModel.set 'total', total


  initializeHighlightsSlider: =>

    @highlightViews = _.map @model.highlights(), (highlight) =>
      new acorn.player.ClipSelectView
        eventhub: @eventhub
        start: highlight.timeStart
        end: highlight.timeEnd
        min: 0
        max: @model.duration()

    @progressBarView = new acorn.player.HighlightsSliderView
      extraClasses: ['progress-bar-view']
      eventhub: @eventhub
      value: 0
      highlights: @highlightViews


  render: =>
    super
    @$el.empty()

    @$el.append @template()
    @$('.media-view').append @subMediaView.render().el
    @$('.time-controls').append @progressBarView.render().el
    @$('.time-controls').append @controlsView.render().el
    @


  # duration of video given current splicing and looping - get from model
  duration: =>
    @subMediaView?.duration() or @model.duration() or 0


  _setTimeInputMax: =>
    @timeRangeInputView.setMax @model.timeTotal()


  _onMediaProgress: (view, elapsed, total) =>
    # keep progress bar in sync
    @_progress = @model.timeStart() + elapsed
    @timeRangeInputView.progress @_progress


  _onChangeTimes: (changed) =>
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
    unless @subMediaView.isInState 'pause'
      @subMediaView.play()

    if seekOffset?
      # bound between 0 <= seekOffset <= @duration() -2
      seekOffset = Math.max(0, Math.min(seekOffset, @model.duration() - 2))
      @subMediaView.seek seekOffset
      @subMediaView.elapsedLoops 0

    @eventhub.trigger 'change:shell', @model, @


  _onChangeProgress: (progress) =>
    # if slider progress differs from player progress, seek to new position
    unless progress.toFixed(5) == @_progress?.toFixed(5)
      @_progress = progress
      @subMediaView.seek progress


  _onChangeLoops: (changed) =>
    loops = if changed.name == 'n' then changed.value else changed.name
    @model.loops(loops)

    # restart player loops
    @subMediaView.elapsedLoops 0
    if @subMediaView.isPlaying()
      @subMediaView.seek 0


# Register the shell with the acorn object.
acorn.registerShellModule HighlightsShell
