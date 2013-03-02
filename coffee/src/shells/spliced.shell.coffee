goog.provide 'acorn.shells.SplicedShell'

goog.require 'acorn.shells.CollectionShell'
goog.require 'acorn.player.ValueSliderView'


CollectionShell = acorn.shells.CollectionShell


SplicedShell = acorn.shells.SplicedShell =

  id: 'acorn.SplicedShell'
  title: 'Spliced'
  description: 'Media spliced together'
  icon: 'icon-play'



class SplicedShell.Model extends CollectionShell.Model


  transition: @property('transition')



class SplicedShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'spliced-shell'


  events: => _.extend super,
    'click .click-capture': => @togglePlayPause()


  defaults: => _.extend super,
    playOnReady: true
    subshellPlayOnReady: false
    showSubshellControls: false
    showSubshellSummary: false
    autoAdvanceOnEnd: true


  initializeSubshellMediaView: (shellModel) =>
    view = super

    # hide subshell progress bars
    view.progressBarView?.$el.addClass 'hidden'

    view


  initializeControlsView: =>

    @initializeElapsedTimeView()
    @initializeProgressBarView()

    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Play', 'Pause', @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()
    @controlsView.on 'ElapsedTimeControl:Seek', @seek


  initializeElapsedTimeView: =>

    tvModel = new Backbone.Model
      elapsed: 0
      total: @duration() or 0

    @elapsedTimeView = new acorn.player.controls.ElapsedTimeControlView
      eventhub: @eventhub
      model: tvModel

    tvModel.listenTo @, 'Media:Progress', (view, elapsed, total) =>
      tvModel.set 'elapsed', elapsed
      tvModel.set 'total', total or 0


  initializeProgressBarView: =>
    @progressBarView = new acorn.player.ValueSliderView
      eventhub: @eventhub
      value: 0
      extraClasses: 'progress-bar-view'

    # keep progress bar in sync with media
    @progressBarView.listenTo @, 'Media:Progress', (view, elapsed, total) =>
      @progressBarView.value @percentProgress()

    @listenTo @progressBarView, 'ValueSliderView:ValueDidChange',
        @_onChangeProgressPercent


  remove: =>
    @controlsView.off 'PlayControl:Click'
    @controlsView.off 'PauseControl:Click'
    super


  render: =>
    super

    # render all pieces in order to get them fully ready
    # this will be expensive as the # of pieces incs.
    _.each _.range(1, @shellViews.length), (index) =>
      @showView index
      @shellViews[index].pause()
      @hideView index
    @showView 0

    @$el.append $('<div>').addClass('click-capture')

    # TODO: move progress bar to controlsView or an equivalent
    @$el.append @progressBarView.render().el

    @


  seekOffset: =>
    viewsBefore = _.map _.range(@currentIndex), @shellView
    @shellView().seekOffset() + @duration viewsBefore


  seek: (offset) =>
    for index in _.range @shellViews.length
      view = @shellView index
      if offset >= view.duration()
        offset -= view.duration()
        continue

      @switchShell index
      view.seek offset
      return


  _onChangeProgressPercent: (percentProgress) =>
    progress = @progressFromPercent percentProgress

    # if slider progress differs from player progress, seek to new position
    unless progress.toFixed(5) == @seekOffset().toFixed(5)
      @seek progress


  showNext: =>
    @shellView(@currentIndex + 1)?.seek 0
    super


  onMediaDidPlay: =>
    super
    @controlsView.$('.control-view.play').addClass 'hidden'
    @controlsView.$('.control-view.pause').removeClass 'hidden'


  onMediaDidPause: =>
    super
    @controlsView.$('.control-view.play').removeClass 'hidden'
    @controlsView.$('.control-view.pause').addClass 'hidden'


  onMediaDidEnd: =>
    @controlsView.$('.control-view.play').removeClass 'hidden'
    @controlsView.$('.control-view.pause').addClass 'hidden'



class SplicedShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'spliced-shell'


  defaultAttributes: =>
    superDefaults = super

    _.extend superDefaults,
      title: @model.shells().first()?.title() ? superDefaults.title



acorn.registerShellModule SplicedShell
