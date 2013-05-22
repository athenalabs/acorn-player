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
        @play()

      clipView

    @progressBarView = new acorn.player.HighlightsSliderView
      extraClasses: ['progress-bar-view']
      eventhub: @eventhub
      handle: false
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


  controlsTemplate: _.template '''
    <div class="highlight-button">
      <button class="btn btn-small add-highlight">
        <i class="icon-plus"></i> Highlight</button>
    </div>

    <div class="note-input input-append">
      <input type="text" class="note input" placeholder="clip note" />
      <button class="note btn btn-small btn-success">
        <i class="icon-ok"></i></button>
    </div>
    '''

  events: => _.extend super,
    'click button.add-highlight': => @_addHighlight()
    'blur input.note': => @_saveHighlightNote()
    'keyup input.note': (event) =>
      switch event.keyCode
        when athena.lib.util.keys.ENTER
          @_saveHighlightNote()
          @_inactivateHighlights()
        when athena.lib.util.keys.ESCAPE
          @_inactivateHighlights()
    'click .note.btn.btn-success': =>
      @_saveHighlightNote()
      @_inactivateHighlights()


  initialize: =>
    super

    # if no highlights, use default empty array
    @model.highlights @model.highlights()

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


  initializeControls: =>
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: [@playPauseToggleView, @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @subMediaView.play()
    @controlsView.on 'PauseControl:Click', => @subMediaView.pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @subMediaView.seek


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

    @highlightViews = _.map @model.highlights(), @initializeHighlightView

    @clipGroupView = new acorn.player.ClipGroupView
      eventhub: @eventhub
      clips: @highlightViews


  initializeHighlightView: (highlight) =>
    clipView = new acorn.player.ClipSelectView
      eventhub: @eventhub
      clip: highlight
      start: highlight.timeStart
      end: highlight.timeEnd
      min: 0
      max: @model.duration()

    # change highlight times.
    clipView.inputView.on 'TimeRangeInputView:DidChangeTimes', =>
      highlight.timeStart = changed.start if _.isNumber changed?.start
      highlight.timeEnd = changed.end if _.isNumber changed?.end

    # change playback progress.
    clipView.inputView.on 'TimeRangeInputView:DidChangeProgress',
      @_onChangeProgress

    clipView.listenTo @subMediaView, 'Media:Progress',
      (view, elapsed, total) =>
        # keep progress bar in sync
        @_progress = highlight.timeStart + elapsed
        clipView.inputView.progress @_progress

    clipView.on 'ClipSelect:Active', (clipView) =>
      # inactivate all other highlights when one comes active
      _.each @highlightViews, (highlightView) =>
        unless highlightView is clipView
          highlightView.toggleActive false

      # adjust clip note inputs
      @$('.note-input button').first().removeAttr('disabled')
      @$('.note-input input').first().removeAttr('disabled')
        .val(highlight.title).focus()

    clipView.on 'ClipSelect:Inactive', =>
      # adjust clip note inputs
      @$('.note-input button').first().attr('disabled', 'disabled')
      @$('.note-input input').first().attr('disabled', 'disabled').val('')

    clipView


  render: =>
    super
    @$el.empty()

    @$el.append @template()
    @$('.media-view').first().append @subMediaView.render().el
    @$('.time-controls').first()
      .append(@clipGroupView.render().el)
      .append(@controlsView.render().el)

    @controlsView.$el.append @controlsTemplate()
    @$('.note-input button').first().tooltip
      trigger: 'hover'
      title: 'Enter Clip Note'

    @_inactivateHighlights()
    @


  # duration of video given current splicing and looping - get from model
  duration: =>
    @subMediaView?.duration() or @model.duration() or 0


  _setTimeInputMax: =>
    @timeRangeInputView.setMax @model.timeTotal()


  _onChangeTimes: (changed) =>
    changes = {}
    changes.timeStart = changed.start if _.isNumber changed?.start
    changes.timeEnd = changed.end if _.isNumber changed?.end


    # calculate seekOffset before changes take place.
    if changes.timeStart? and changes.timeStart isnt @model.timeStart()
      seekOffset = 0
    else if changes.timeEnd? and changes.timeEnd isnt @model.timeEnd()
      seekOffset = Infinity # will be bounded to duration after changes

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


  _activeHighlight: =>
    _.find @highlightViews, (highlightView) =>
      highlightView.isActive()


  _saveHighlightNote: =>
    @_activeHighlight()?.clip.title = @$('.note-input input').first().val()


  _inactivateHighlights: =>
    _.each @highlightViews, (highlightView) =>
      highlightView.toggleActive false
    @$('input.note').first().blur()


  _addHighlight: =>
    highlight =
      timeStart: 0
      timeEnd: @duration()
      title: ''

    @model.highlights().push highlight
    @highlightViews.push @initializeHighlightView highlight
    @_inactivateHighlights()
    @clipGroupView.softRender()


# Register the shell with the acorn object.
acorn.registerShellModule HighlightsShell
