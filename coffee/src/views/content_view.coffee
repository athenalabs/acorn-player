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
# |                       Shell.MediaView                          |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# ------------------------------------------------------------------
# | Shell.MediaView:controlsView         ContentView:acornControls |
# ------------------------------------------------------------------


# View to experience an acorn. Renders shells' MediaViews, and the controls.
class acorn.player.ContentView extends athena.lib.View


  className: @classNameExtend 'content-view'


  acornControls: [
    'Sources',
    'Edit',
    'Acorn',
    'Fullscreen',
  ]


  events: => _.extend super,
    'mousemove': @onMouseMoved

  initialize: =>
    super
    # should these go here?
    # @model.shellModel.on 'change', @render
    # @model.acornModel.on 'change', @render

    # construct a shell MediaView
    shellModel = acorn.shellWithAcorn @model
    @shellView = new shellModel.module.MediaView
      model: shellModel
      eventhub: @eventhub
      playOnReady: true

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

    # grab shellView summaryView
    @summaryView = @shellView.summaryView

    # construct main ControlToolbar
    @controlsView = new ControlToolbarView
      buttons: [@acornControlsView, @shellControlsView]
      eventhub: @eventhub

    # alignments
    @acornControlsView.$el.addClass 'right'
    @shellControlsView.$el.addClass 'left'

    # setup events
    @acornControlsView.on 'all', (name) => @eventhub.trigger name
    @eventhub.on 'Keypress:SPACEBAR', => @shellView.togglePlayPause()


  render: =>
    super
    @$el.empty()

    # add controlsView to DOM first so that shellView can interact with it
    @$el.append @summaryView.render().el
    @$el.append @controlsView.render().el
    @$el.prepend @shellView.render().el

    # for now, hide sources control
    @acornControlsView.$('.control-view.sources').addClass 'hidden'
    @


  onMouseMoved: (event) =>
    @$el.addClass 'mouse-moving'
    mousePos = "#{event.clientX},#{event.clientY}"
    @_lastMousePos = mousePos
    setTimeout (=>
      if @_lastMousePos is mousePos
        @onMouseStoppedMoving()
    ), 1000


  onMouseStoppedMoving: =>
    @$el.removeClass 'mouse-moving'
