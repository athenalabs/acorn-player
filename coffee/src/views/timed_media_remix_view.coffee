goog.provide 'acorn.player.TimedMediaRemixView'
goog.require 'acorn.player.TimedMediaPlayerView'


class acorn.player.TimedMediaRemixView extends athena.lib.View


  className: @classNameExtend 'timed-media-remix-view'


  template: _.template '''
    <div class='media-view'></div>
    <div class='time-controls'></div>
    '''


  initialize: =>
    super

    @initializeMediaView()
    @initializeProgressBar()
    @initializePlayPauseToggleView()
    @initializeElapsedTimeView()
    @initializeControls()


  initializeMediaView: =>
    @mediaView = new @model.module.MediaView
      model: @model
      eventhub: @eventhub
      playOnReady: @options.playOnReady

    @listenTo @mediaView, 'all', =>
      # replace @mediaView with @
      args = _.map arguments, (arg) =>
        if arg is @mediaView then @ else arg

      @trigger.apply @, args

    @listenTo @mediaView, 'Media:StateChange', =>
      @playPauseToggleView.refreshToggle()

    @listenTo @mediaView, 'Media:Progress', (view, elapsed, total) =>
      # keep progress bar in sync
      @progressBarView.value elapsed, {silent: true}


  initializeProgressBar: =>
    @progressBarView = new acorn.player.ValueSliderView
      handle: false
      extraClasses: ['progress-bar-view']
      eventhub: @eventhub
      value: 0
      max: @mediaView.duration()

    @progressBarView.on 'ValueSliderView:ValueDidChange', @onProgressBarChange


  initializeControls: =>
    @controlsView = new acorn.player.controls.ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: [@playPauseToggleView, @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @mediaView.play()
    @controlsView.on 'PauseControl:Click', => @mediaView.pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @mediaView.seek


  initializePlayPauseToggleView: =>
    model = new Backbone.Model
    model.isPlaying = => @mediaView.isPlaying()

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

    tvModel.listenTo @mediaView, 'Media:Progress', (view, elapsed, total) =>
      tvModel.set 'elapsed', elapsed + (@model.timeStart?() || 0)
      tvModel.set 'total', @model.timeTotal?() || total


  render: =>
    super
    @$el.empty()

    @$el.append @template()
    @$('.media-view').first().append @mediaView.render().el
    @$('.time-controls').first()
      .append(@progressBarView.render().el)
      .append(@controlsView.render().el)

    @


  # duration of video given current splicing and looping - get from model
  duration: =>
    @mediaView?.duration() or @model.duration() or 0


  onProgressBarChange: (percentProgress) =>

    progress = util.fromPercent percentProgress,
      low: 0
      high: @mediaView.duration()
      bound: true

    if progress?
      @mediaView.seek progress
