goog.provide 'acorn.player.ContentView'

goog.require 'acorn.player.ValueSliderView'
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
    'mouseenter .summary-view': @onMouseenterSummaryView
    'mouseleave .summary-view': @onMouseleaveSummaryView


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

    # construct a progressBarView
    @progressBarView = new acorn.player.ValueSliderView
      handle: false
      extraClasses: ['progress-bar-view']
      eventhub: @eventhub
      value: 0

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
    @progressBarView.on 'ValueSliderView:ValueDidChange',
        @_onProgressBarValueChange
    @shellView.on 'Shell:UpdateProgressBar', @_onUpdateProgressBar
    @eventhub.on 'Keypress:SPACEBAR', => @shellView.togglePlayPause()
    @eventhub.on 'show:editor', => @shellView.pause()


  render: =>
    super
    @$el.empty()

    @$el.append @summaryView.render().el
    @$el.append @progressBarView.render().el
    @$el.append @controlsView.render().el

    # Add shellView last so that it can interact with other views.
    # ShellView must follow progressBarView in order to be sized correctly.
    @$el.append @shellView.render().el

    # for now, hide sources control
    @acornControlsView.$('.control-view.sources').addClass 'hidden'
    @


  _onProgressBarValueChange: (percentProgress) =>
    @shellView.trigger 'ProgressBar:DidProgress', percentProgress


  _onUpdateProgressBar: (visible, percentProgress) =>
    if visible
      @progressBarView.$el.removeClass 'hidden'
      @progressBarView.value percentProgress
    else
      @progressBarView.$el.addClass 'hidden'


  onMouseenterSummaryView: =>
    clearTimeout @_summaryHoverTimeout
    @summaryView.$el.addClass 'opaque opaque-lock'

    # lock opaque for 2 seconds
    @_summaryHoverTimeout = setTimeout (=>
      @summaryView.$el.removeClass 'opaque-lock'
    ), 1500


  onMouseleaveSummaryView: =>
    @summaryView.$el.removeClass 'opaque'


  onMouseMoved: (event) =>
    @$el.addClass 'mouse-moving'
    mousePos = "#{event.clientX},#{event.clientY}"
    @_lastMousePos = mousePos
    setTimeout (=>
      if @_lastMousePos is mousePos
        @onMouseStoppedMoving()
    ), 2000


  onMouseStoppedMoving: =>
    @$el.removeClass 'mouse-moving'
