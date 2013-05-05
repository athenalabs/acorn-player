goog.provide 'acorn.shells.GalleryShell'

goog.require 'acorn.shells.CollectionShell'



CollectionShell = acorn.shells.CollectionShell


GalleryShell = acorn.shells.GalleryShell =

  id: 'acorn.GalleryShell'
  title: 'Gallery'
  description: 'media displayed in a gallery'
  icon: 'icon-th'



class GalleryShell.Model extends CollectionShell.Model



class GalleryShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'gallery-shell'


  tileOptions:
    tileVars: (model) ->
      {link: '', thumbnail: model.thumbnail()}


  defaults: => _.extend super,
    playOnReady: false
    readyOnRender: true
    showFirstSubshellOnRender: false
    showSubshellControls: true
    showSubshellSummary: true
    autoAdvanceOnEnd: false
    playSubshellOnProgression: true
    shellsCycle: true


  initialize: =>
    super

    @gridView = new athena.lib.GridView
      collection: @model.shells()
      eventhub: @eventhub
      tileOptions: @tileOptions

    @listenTo @gridView, 'GridTile:Click', (tile) =>
      @switchShell @model.shells().indexOf tile.model
      @play()
      return false


  initializeControlsView: =>
    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Previous', 'Grid', 'Next']
      eventhub: @eventhub

    @listenTo @controlsView, 'PreviousControl:Click', => @showPrevious()
    @listenTo @controlsView, 'GridControl:Click', => @showGrid()
    @listenTo @controlsView, 'NextControl:Click', => @showNext()


  render: =>
    super
    @$el.append @gridView.render().el
    @showGrid()
    @


  showGrid: =>
    @hideView()
    @gridView.$el.show()
    @controlsView.$el.hide()
    @


  hideGrid: =>
    @gridView.$el.hide()
    @controlsView.$el.show()
    @


  showView: =>
    @hideGrid()
    super



class GalleryShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'gallery-shell'



acorn.registerShellModule GalleryShell
