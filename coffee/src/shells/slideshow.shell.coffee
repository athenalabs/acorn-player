goog.provide 'acorn.shells.SlideshowShell'

goog.require 'acorn.shells.CollectionShell'



CollectionShell = acorn.shells.CollectionShell


SlideshowShell = acorn.shells.SlideshowShell =

  id: 'acorn.SlideshowShell'
  title: 'Slideshow'
  description: 'Media displayed in a slideshow.'
  icon: 'icon-play-circle'



class SlideshowShell.Model extends CollectionShell.Model


  delay: @property('delay', default: 5)



class SlideshowShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'slideshow-shell'


  defaults: => _.extend super,
    playOnReady: true
    autoAdvanceOnEnd: false


  initializeSubshellEvents: =>
    super

    @on 'Subshell:Media:DidEnd', =>
      if @isPlaying() and not @_counter?
        @showNext()


  initializeControlsView: =>
    @initializePlayPauseToggleView()

    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Previous', @playPauseToggleView, 'Next']
      eventhub: @eventhub

    @controlsView.on 'PreviousControl:Click', @showPrevious
    @controlsView.on 'NextControl:Click', @showNext
    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()


  initializePlayPauseToggleView: =>
    model = new Backbone.Model
    model.isPlaying = => @isPlaying()

    @playPauseToggleView = new acorn.player.controls.PlayPauseControlToggleView
      eventhub: @eventhub
      model: model


  remove: =>
    @controlsView.off 'PreviousControl:Click', @showPrevious
    @controlsView.off 'NextControl:Click', @showNext
    @controlsView.off 'PlayControl:Click'
    @controlsView.off 'PauseControl:Click'

    @_clearCountdown()
    super


  onMediaDidPlay: =>
    @playPauseToggleView.refreshToggle()
    @_countdown()


  onMediaDidPause: =>
    @playPauseToggleView.refreshToggle()
    @_clearCountdown()


  onMediaDidEnd: =>
    @playPauseToggleView.refreshToggle()
    @_clearCountdown()


  showNext: =>
    super
    @_countdown()


  showPrevious: =>
    super
    @_countdown()


  _countdown: =>
    @_clearCountdown()

    if @isPlaying()
      @_counter = setTimeout @_onCountdownFinish, @model.delay() * 1000


  _clearCountdown: =>
    clearTimeout @_counter
    @_counter = undefined


  _onCountdownFinish: =>
    @_clearCountdown()

    view = @shellViews[@currentIndex]

    if @isPlaying()
      unless 0 < view?.duration?() < Infinity and view.isPlaying()
        @showNext()



class SlideshowShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'slideshow-shell'


  initialize: =>
    super

    @timeInputView = new acorn.player.TimeInputView
      name: 'delay:'
      value: @model.delay()
      min: 0
      max: Infinity
      padTime: false
      extraClasses: ['slide-delay']
    @timeInputView.on 'TimeInputView:TimeDidChange', @_onTimeInputChanged


  render: =>
    super
    @$el.append @timeInputView.render().el
    @


  _onTimeInputChanged: (delay) =>
    @model.delay delay



acorn.registerShellModule SlideshowShell
