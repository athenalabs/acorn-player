goog.provide 'acorn.shells.GalleryShell'

goog.require 'acorn.shells.CollectionShell'



CollectionShell = acorn.shells.CollectionShell


GalleryShell = acorn.shells.GalleryShell =

  id: 'acorn.GalleryShell'
  title: 'GalleryShell'
  description: 'Gallery shell'
  icon: 'icon-th'



class GalleryShell.Model extends CollectionShell.Model



class GalleryShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'gallery-shell'


  tileOptions:
    tileVars: (model) ->
      {link: '', thumbnail: model.thumbnail()}


  initialize: =>
    super

    @gridView = new athena.lib.GridView
      collection: @model.shells()
      eventhub: @eventhub
      tileOptions: @tileOptions

    @listenTo @gridView, 'GridTile:Click', (tile) =>
      @showView @model.shells().indexOf tile.model


  _initializeControlsView: =>
    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Previous', 'Grid', 'Next']
      eventhub: @eventhub

    @controlsView.on 'PreviousControl:Click', => @showPrevious()
    @controlsView.on 'GridControl:Click', => @hideView()
    @controlsView.on 'NextControl:Click', => @showNext()


  remove: =>
    @controlsView.off 'GridControl:Click', @onTogglePlaylist
    super


  render: =>
    super
    @$el.append @gridView.render().el
    @hideView()
    @


  hideView: =>
    super
    @gridView.$el.show()
    @controlsView.$el.hide()


  showView: =>
    super
    @gridView.$el.hide()
    @controlsView.$el.show()



class GalleryShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'gallery-shell'



acorn.registerShellModule GalleryShell
