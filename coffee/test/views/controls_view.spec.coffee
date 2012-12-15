goog.provide 'acorn.specs.player.ControlsView'

goog.require 'acorn.player.ControlsView'


describe 'acorn.player.ControlsView', ->
  ControlsView = acorn.player.ControlsView

  it 'should be part of acorn.player', ->
    expect(ControlsView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ControlsView, athena.lib.View

  describe 'should subdivide itself into acorn controls and shell controls, ' +
      'and', ->
    cv = new ControlsView()

    it 'should contain an AcornControlsView instance', ->
      expect(cv.acornControls instanceof acorn.player.AcornControlsView)
          .toBe true

    it 'should contain an ShellControlsView instance', ->
      expect(cv.shellControls instanceof acorn.player.ShellControlsView)
          .toBe true

    it 'should contain both controls views in a "controlSubviews" property', ->
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


describe 'acorn.player.ControlsSubview', ->
  ControlsSubview = acorn.player.ControlsSubview

  it 'should be part of acorn.player', ->
    expect(ControlsSubview).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ControlsSubview, athena.lib.View).toBe true

  it 'should have method "initializeControlViews"', ->
    expect(typeof ControlsSubview::initializeControlViews).toBe 'function'

  it 'should have method "validControl"', ->
    expect(typeof ControlsSubview::validControl).toBe 'function'

  it 'should have method "controlWithId"', ->
    expect(typeof ControlsSubview::controlWithId).toBe 'function'

  # TODO: test functionality
  # this is waiting on the construction of ControlViews
  xit '.initializeControlViews() should initialize control views', ->
  xit '.validControl(ControlView) should validate a ControlView class', ->
  xit '.controlWithId(id) should return control with id if it exists', ->
  xit 'should render a control panel', ->


describe 'acorn.player.AcornControlsView', ->
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


describe 'acorn.player.ShellControlsView', ->
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

    # TODO: un-stub initializeControlViews. necessary until ControlViews exist
    scv = new ShellControlsView()
    spyOn(scv, 'initializeControlViews')
    scv.setControls controls

    expect(scv.controls.length).toBe controls.length
    _.each scv.controls, (ctrl) ->
      expect(_.contains controls, ctrl).toBe true

  it 'should initialize control views when controls are set', ->
    controls = [
      'TwistIt'
      'PullIt'
      'FlickIt'
      'SpinIt'
      'BopIt'
    ]

    scv = new ShellControlsView()
    spy = spyOn(scv, 'initializeControlViews')
    scv.setControls controls

    # TODO: test functionality, not just that function was called
    expect(spy).toHaveBeenCalled()

  # TODO: test render functionality
  # this is waiting on the construction of ControlViews
  xit 'should render a control panel with shell controls', ->


describe 'acorn.player.SubshellControlsView', ->
  SubshellControlsView = acorn.player.SubshellControlsView

  it 'should be part of acorn.player', ->
    expect(SubshellControlsView).toBeDefined()

  it 'should derive from acorn.player.ShellControlsView', ->
    expect(athena.lib.util.derives SubshellControlsView,
        acorn.player.ShellControlsView).toBe true

  # TODO: test shell controls subdivision functionality
  # this is waiting on the construction of ControlViews
  xit 'should enable subdivision of shell controls panel', ->


describe 'ControlsViews, generally', ->
  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new acorn.player.ControlsView
    $player.append view.render().el
