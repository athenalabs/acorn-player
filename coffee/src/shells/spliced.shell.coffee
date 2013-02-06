goog.provide 'acorn.shells.SplicedShell'

goog.require 'acorn.shells.CollectionShell'


CollectionShell = acorn.shells.CollectionShell


SplicedShell = acorn.shells.SplicedShell =

  id: 'acorn.SplicedShell'
  title: 'Spliced'
  description: 'Media spliced together'
  icon: 'icon-play'



class SplicedShell.Model extends CollectionShell.Model


  transition: @property('transition')


  title: =>
    super or @shells().first()?.title() or ''



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


  initializeControlsView: =>

    @initializeElapsedTimeView()

    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Play', 'Pause', @elapsedTimeView]
      eventhub: @eventhub

    @controlsView.on 'PlayControl:Click', => @play()
    @controlsView.on 'PauseControl:Click', => @pause()


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




class SplicedShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'slideshow-shell'



acorn.registerShellModule SplicedShell
