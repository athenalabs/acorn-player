goog.provide 'acorn.player.ControlsView'

# view with media control buttons
class acorn.player.ControlsView extends athena.lib.View

  className: @classNameExtend 'controls-view'

  initialize: =>
    super

    @acornControls = new acorn.player.AcornControlsView eventhub: @eventhub
    @shellControls = new acorn.player.ShellControlsView eventhub: @eventhub
    @controlSubviews = [@acornControls, @shellControls]

  render: =>
    @$el.empty()

    _.each @controlSubviews, (csv) =>
      @$el.append csv.render().el

    @

  controlWithId: (id) =>
    _.each @controlSubviews, (csv) =>
      control = csv.controlWithId id
      return control if control

    undefined


# a subcomponent view for ControlsView
class acorn.player.ControlsSubview extends athena.lib.View

  className: @classNameExtend 'controls-subview'

  initialize: =>
    super
    @initializeControlViews()

  render: =>
    @$el.empty()

    _.each @controlViews, (cv) =>
      cv.delegateEvents()
      @$el.append cv.render().el

    @

  initializeControlViews: =>
    @controls ?= []

    @controlViews = _(@controls).chain()
      .map((ctrl) => acorn.player[ctrl])
      .filter((ctrl) => @validControl ctrl)
      .map((ctrl) => new ctrl controls: @, eventhub: @eventhub)
      .value()

  validControl: (ControlView) =>
    athena.lib.util.derives ControlView, acorn.player.ControlItemView ||
      ControlView == acorn.player.SubshellControlsView

  controlWithId: (id) =>
    _.find @controlViews, (cv) ->
      cv.id == id

# view with acorn control buttons
class acorn.player.AcornControlsView extends acorn.player.ControlsSubview

  className: @classNameExtend 'acorn-controls-view'

  initialize: =>
    super
    @controls = _.clone acorn.player.AcornControlsView.controls

  # universal acorn controls
  @controls = [
    'FullscreenControlView'
    'AcornControlView'
    'SourcesControlView'
    'EditControlView'
  ]


# view with shell control buttons
class acorn.player.ShellControlsView extends acorn.player.ControlsSubview

  className: @classNameExtend 'shell-controls-view'

  #api function enabling a shell to set its controls
  setControls: (controls) =>
    @controls = _.clone controls if _.isArray controls
    @initializeControlViews()

    @softRender()


# view with control buttons for subshell
#
# This view can be used to subdivide ControlsView. It is passed into
# ControlsView as though it were an individual control.
class acorn.player.SubshellControlsView extends acorn.player.ShellControlsView

  className: @classNameExtend 'subshell-controls-view'
