goog.provide 'acorn.shells.SplicedShell'

goog.require 'acorn.shells.CollectionShell'


CollectionShell = acorn.shells.CollectionShell


SplicedShell = acorn.shells.SplicedShell =

  id: 'acorn.SplicedShell'
  title: 'SplicedShell'
  description: 'Splice acorns together'
  icon: 'icon-play'



class SplicedShell.Model extends CollectionShell.Model


  transition: @property('transition')



class SplicedShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'spliced-shell'


  defaults: => _.extend super,
    playOnReady: true
    subshellPlayOnReady: false
    showSubshellControls: false
    showSubshellSummary: false
    autoAdvanceOnEnd: true


  initialize: =>
    super

    @on 'Subshell:Media:DidPlay', @play
    @on 'Subshell:Media:DidPause', @pause


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
    _.each _.range(@shellViews.length), (index) =>
      @showView index
      @shellViews[index].pause()
    @showView 0
    @


  onMediaDidPlay: =>
    @controlsView.$('.control-view.play').addClass 'hidden'
    @controlsView.$('.control-view.pause').removeClass 'hidden'


  onMediaDidPause: =>
    @controlsView.$('.control-view.play').removeClass 'hidden'
    @controlsView.$('.control-view.pause').addClass 'hidden'




class SplicedShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'slideshow-shell'



acorn.registerShellModule SplicedShell
