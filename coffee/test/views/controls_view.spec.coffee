goog.provide 'acorn.specs.player.ControlsView'

goog.require 'acorn.player.ControlsView'


# ControlsView
# ------------
describe 'acorn.player.ControlsView', ->
  ControlsView = acorn.player.ControlsView

  it 'should be part of acorn.player', ->
    expect(ControlsView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ControlsView, athena.lib.View).toBe true

  describe 'should subdivide itself into acorn controls and shell controls, ' +
      'and', ->
    cv = new ControlsView()

    it 'should contain an AcornControlsView instance', ->
      expect(cv.acornControls instanceof acorn.player.AcornControlsView)
          .toBe true

    it 'should contain an ShellControlsView instance', ->
      expect(cv.shellControls instanceof acorn.player.ShellControlsView)
          .toBe true

    it 'should contain both control views in a "controlSubviews" property', ->
      csvs = [cv.acornControls, cv.shellControls]

      expect(cv.controlSubviews.length).toBe csvs.length
      _.each cv.controlSubviews, (csv) ->
        expect(_.contains csvs, csv).toBe true

  it 'should have method "controlWithId"', ->
    expect(typeof ControlsView::controlWithId).toBe 'function'

  # TODO: test controlWithId and render functionality
  # this is waiting on the construction of ControlViews
  xit '.controlWithId(id) should farm query to control subviews', ->
  xit 'should render a control panel with acorn and shell controls', ->

# ControlsSubview
# ---------------
describe 'acorn.player.ControlsSubview', ->
  ControlsSubview = acorn.player.ControlsSubview

  it 'should be part of acorn.player', ->
    expect(ControlsSubview).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ControlsSubview, athena.lib.View).toBe true

  it 'should have method "constructControlViews"', ->
    expect(typeof ControlsSubview::constructControlViews).toBe 'function'

  it 'should have method "validControl"', ->
    expect(typeof ControlsSubview::validControl).toBe 'function'

  it 'should have method "controlWithId"', ->
    expect(typeof ControlsSubview::controlWithId).toBe 'function'

  # TODO: test functionality
  # this is waiting on the construction of ControlViews
  xit '.constructControlViews() should construct control views', ->
  xit '.validControl(ControlView) should validate a ControlView class', ->
  xit '.controlWithId(id) should return control with id if it exists', ->
  xit 'should render a control panel', ->


# AcornControlsView
# -----------------
describe 'acorn.player.Acorn.ControlsView', ->
  AcornControlsView = acorn.player.AcornControlsView

  it 'should be part of acorn.player', ->
    expect(AcornControlsView).toBeDefined()

  it 'should derive from acorn.player.ControlsSubview', ->
    expect(athena.lib.util.derives AcornControlsView,
        acorn.player.ControlsSubview).toBe true

  it 'should list acorn control names on static property "controls"', ->
    acornControls = [
      'FullscreenControlView'
      'AcornControlView'
      'SourcesControlView'
      'EditControlView'
    ]

    expect(AcornControlsView.controls.length).toBe acornControls.length
    _.each acornControls, (ctrl) ->
      expect(_.contains AcornControlsView.controls, ctrl).toBe true

  it 'should set controls property to mirror static controls on initialize', ->
    acv = new AcornControlsView()

    expect(acv.controls.length).toBe AcornControlsView.controls.length
    _.each acv.controls, (ctrl) ->
      expect(_.contains AcornControlsView.controls, ctrl).toBe true

  # TODO: test render functionality
  # this is waiting on the construction of ControlViews
  xit 'should render a control panel with acorn controls', ->

# ShellControlsView
# -----------------
describe 'acorn.player.Shell.ControlsView', ->
  ShellControlsView = acorn.player.ShellControlsView

  it 'should be part of acorn.player', ->
    expect(ShellControlsView).toBeDefined()

  it 'should derive from acorn.player.ControlsSubview', ->
    expect(athena.lib.util.derives ShellControlsView,
        acorn.player.ControlsSubview).toBe true

  it 'should have method "setControls"', ->
    expect(typeof ShellControlsView::setControls).toBe 'function'

  it 'should set controls property with setControls method', ->
    controls = [
      'TwistIt'
      'PullIt'
      'FlickIt'
      'SpinIt'
      'BopIt'
    ]

    scv = new ShellControlsView()
    scv.setControls controls

    expect(scv.controls.length).toBe controls.length
    _.each scv.controls, (ctrl) ->
      expect(_.contains controls, ctrl).toBe true

  # TODO: test render functionality
  # this is waiting on the construction of ControlViews
  xit 'should render a control panel with shell controls', ->

# SubshellControlsView
# --------------------
describe 'acorn.player.Subshell.ControlsView', ->
  SubshellControlsView = acorn.player.SubshellControlsView

  it 'should be part of acorn.player', ->
    expect(SubshellControlsView).toBeDefined()

  it 'should derive from acorn.player.ShellControlsView', ->
    expect(athena.lib.util.derives SubshellControlsView,
        acorn.player.ShellControlsView).toBe true

  # TODO: test shell controls subdivision functionality
  # this is waiting on the construction of ControlViews
  xit 'should enable subdivision of shell controls panel', ->
