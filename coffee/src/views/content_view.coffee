goog.provide 'acorn.player.ContentView'

goog.require 'acorn.player.controls.ControlToolbarView'
goog.require 'acorn.shells.Shell'

ControlToolbarView = acorn.player.controls.ControlToolbarView

# acorn Player:
# ------------------------------------------------------------------
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                      Shell.ContentView                         |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# ------------------------------------------------------------------
# | Shell.ContentView::controlsView     ContentView::acornControls |
# ------------------------------------------------------------------


# View to experience an acorn. Renders shells' ContentViews, and the controls.
class acorn.player.ContentView extends athena.lib.View

  className: @classNameExtend 'content-view'

  acornControls: [
    'Sources',
    'Edit',
    'Acorn',
    'Fullscreen',
  ]

  initialize: =>
    # should these go here?
    # @model.shellModel.on 'change', @render
    # @model.acornModel.on 'change', @render

    # construct a shell ContentView
    @shellView = new @model.shellModel.module.ContentView
      model: @model.shellModel
      eventhub: @eventhub

    # construct a ControlToolbar for the acorn controls
    @acornControlsView = new ControlToolbarView
      extraClasses: ['acorn-controls']
      buttons: @acornControls
      eventhub: @eventhub

    # grab customly defined shellView controlsView, or construct one
    @shellControlsView = @shellView.controlsView
    @shellControlsView ?= new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: @shellView.controls
      eventhub: @eventhub

    # construct main ControlToolbar
    @controlsView = new ControlToolbarView
      buttons: [@acornControlsView, @shellControlsView]
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    # add controlsView to DOM first so that shellView can interact with it
    @$el.append @controlsView.render().el
    @$el.prepend @shellView.render().el

    @
