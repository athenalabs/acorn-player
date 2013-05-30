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
  description: 'Media with highlights and notes.'
  icon: 'icon-pencil'



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


  events: => _.extend super,
    'mousemove': @onMouseMove
    'mouseleave': @onMouseLeave


  initialize: =>
    super

    @initializePlayPauseToggleView()
    @initializeElapsedTimeView()
    @initializeHighlightsViews()

    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: [@playPauseToggleView, @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @seek


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


  initializeHighlightsViews: =>

    @highlightViews = @options.highlightViews
    @highlightViews ?= _.map @model.highlights(), (highlight) =>
      clipView = new acorn.player.ClipView
        eventhub: @eventhub
        model: highlight
        min: 0
        max: @model.duration()

      clipView.on 'Clip:Click', (clipView) =>
        @seek clipView.model.timeStart
        @play()

      clipView

    @highlightsGroupView = new acorn.player.ClipGroupView
      clips: @highlightViews
      eventhub: @eventhub

    @on 'Shell:UpdateProgressBar', (visible, percentProgress) =>
      progress = @progressFromPercent percentProgress

      # if progressed to a highlight, show it.
      _.each @highlightViews, (highlightView) =>
        values = highlightView.values()
        if values.start <= progress <= values.end
          highlightView.setActive true
        else
          highlightView.setActive false




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
    @$el.append @highlightsGroupView.render().el
    @playPauseToggleView.refreshToggle()
    @


  _onProgressBarDidProgress: (percentProgress) =>
    @seek @progressFromPercent percentProgress


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


  onMouseMove: (event) =>
    _.each @highlightViews, (highlightView) =>
      offset = highlightView.$el.offset().left
      width = highlightView.$el.width()
      if offset <= event.clientX <= (offset + width)
        highlightView.showNote()
      else
        highlightView.hideNote()


  onMouseLeave: (event) =>
    _.each @highlightViews, (highlightView) =>
      highlightView.hideNote()



class HighlightsShell.RemixView extends Shell.RemixView


  className: @classNameExtend 'highlights-shell'


  controlsTemplate: _.template '''
    <div class="highlight-button">
      <button class="btn btn-small add-highlight">
        <i class="icon-plus"></i> Highlight</button>
    </div>
    '''

  events: => _.extend super,
    'click': => @inactivateHighlights()
    'click button.add-highlight': => @onAddHighlight()
    'keyup textarea.clip-note': (event) =>
      switch event.keyCode
        when athena.lib.util.keys.ENTER
          @onSaveHighlight @activeHighlight()
        when athena.lib.util.keys.ESCAPE
          @onCancelEditHighlight @activeHighlight()


  initialize: =>
    super

    # if no highlights, use default empty array
    @model.highlights @model.highlights()

    @initializeHighlightViews()
    @initializeRemixMediaView()
    @initializeTimeRangeView()


  initializeRemixMediaView: =>
    @mediaView = new @model.module.MediaView
      eventhub: @eventhub
      model: @model
      playOnReady: false
      highlightViews: @highlightViews

    @remixMediaView = new acorn.player.TimedMediaRemixView
      eventhub: @eventhub
      model: @model
      mediaView: @mediaView

    @listenTo @mediaView, 'Media:Progress', (view, elapsed, total) =>
      @timeRangeView?.progress elapsed, {silent: true}


  initializeTimeRangeView: =>

    @timeRangeView = new acorn.player.TimeRangeInputView
      eventhub: @eventhub
      min: 0
      max: @duration()

    @timeRangeView.on 'TimeRangeInputView:DidChangeTimes',
      @onChangeRangeTimes

    @timeRangeView.on 'TimeRangeInputView:DidChangeProgress', (progress) =>
      @mediaView.seek progress


  initializeHighlightViews: =>

    @highlightViews = _.map @model.highlights(), @initializeHighlightView


  initializeHighlightView: (highlight) =>
    clipView = new acorn.player.EditableClipView
      eventhub: @eventhub
      model: highlight
      min: 0
      max: @model.duration()

    clipView.on 'Clip:Toolbar:Click:Clip', => @onClipHighlight clipView
    clipView.on 'Clip:Toolbar:Click:Clip-Save', => @onClipHighlightDone clipView
    clipView.on 'Clip:Toolbar:Click:Edit', => @onEditHighlight clipView
    clipView.on 'Clip:Toolbar:Click:Edit-Save', => @onSaveHighlight clipView
    clipView.on 'Clip:Toolbar:Click:Delete', => @onDeleteHighlight clipView

    clipView


  render: =>
    super
    @$el.empty()

    @$el.append @remixMediaView.render().el

    @remixMediaView.controlsView.$el.append @controlsTemplate()

    @$('.time-controls').prepend @timeRangeView.render().el
    @timeRangeView.$el.hide()

    # @inactivateHighlights()
    @


  # duration of video given current splicing and looping - get from model
  duration: =>
    @remixMediaView?.mediaView?.duration() or @model.duration() or 0


  _setTimeInputMax: =>
    @timeRangeView.setMax @duration()


  onEditHighlight: (highlightView) =>
    @inactivateHighlights [highlightView]
    highlightView.setActive true
    highlightView.$('textarea').focus()


  onClipHighlight: (highlightView) =>
    if @_clippingHighlight
      @onClipHighlightDone()

    @_clippingHighlight = highlightView
    @inactivateHighlights [@_clippingHighlight]
    @_clippingHighlight.clipping true

    @timeRangeView.values @_clippingHighlight.values()
    @timeRangeView.$el.show()
    # @remixMediaView.progressBarView.$el.hide()
    @mediaView.$('.clip-group-view').addClass('clipping')


  onClipHighlightDone: =>
    @timeRangeView.$el.hide()
    # @remixMediaView.progressBarView.$el.show()
    @mediaView.highlightsGroupView.softRender()
    @mediaView.$('.clip-group-view').removeClass('clipping')

    @_clippingHighlight.clipping false
    @_clippingHighlight = undefined


  onSaveHighlight: (highlightView) =>
    @inactivateHighlights() # saves
    highlightView.render()
    highlightView.setActive false


  onCancelEditHighlight: (highlightView) =>
    highlightView?.render() # clears edits
    @inactivateHighlights()


  onDeleteHighlight: (highlightView) =>
    unless highlightView
      return

    if highlightView is @_clippingHighlight
      @onClipHighlightDone()

    @inactivateHighlights()

    # remove from model
    highlights = @model.highlights()
    highlights.splice(highlights.indexOf(highlightView.clip), 1)

    # remove from views
    @highlightViews.splice(@highlightViews.indexOf(highlightView), 1)

    @mediaView.highlightsGroupView.softRender()


  onAddHighlight: =>
    @onClipHighlightDone()

    highlight =
      timeStart: 0
      timeEnd: @duration()
      title: ''

    @model.highlights().push highlight
    view = @initializeHighlightView highlight
    @inactivateHighlights()
    @highlightViews.push view
    @mediaView.highlightsGroupView.softRender()
    view.setActive true


  activeHighlight: =>
    _.find @highlightViews, (highlightView) =>
      highlightView.isActive()

  inactivateHighlights: (except=[]) =>
    except.push @_clippingHighlight

    _.each @highlightViews, (highlightView) =>
      unless highlightView in except
        highlightView.save()
        highlightView.setActive false


  onChangeRangeTimes: (changed) =>
    # calculate seekOffset before changes take place.
    values = @_clippingHighlight.values()
    seekOffset = 0 if changed.start != values.start
    seekOffset = Infinity if changed.end != values.end

    @_clippingHighlight.values changed

    # unless user paused the video, make sure it is playing
    unless @mediaView.isInState 'pause'
      @mediaView.play()

    if seekOffset?
      values = @_clippingHighlight.values()
      seekOffset = Math.min(seekOffset, values.end - 2)
      seekOffset = Math.max(values.start, seekOffset)
      @mediaView.seek seekOffset



# Register the shell with the acorn object.
acorn.registerShellModule HighlightsShell
