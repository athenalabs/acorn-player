goog.provide 'acorn.specs.views.ValueSliderView'

goog.require 'acorn.player.ValueSliderView'
goog.require 'acorn.player.MouseTrackingView'

describe 'acorn.player.ValueSliderView', ->

  ValueSliderView = acorn.player.ValueSliderView
  MouseTrackingView = acorn.player.MouseTrackingView
  EventSpy = athena.lib.util.test.EventSpy

  util = athena.lib.util
  test = util.test

  xdescribe = test.xdescribe


  defaultOpts = ->
    eventhub: _.extend {}, Backbone.Events

  vsvs = []
  afterEach ->
    for vsv in vsvs
      vsv.destroy()
    vsvs = []

  # construct a new slider base view and receive pointers to the view and its
  # handle elements
  setupVSV = (opts = {}) =>
    opts = _.defaults opts, defaultOpts()
    vsv = new ValueSliderView opts
    vsv.render()
    vsvs.push vsv
    vsv


  it 'should be part of acorn.player', ->
    expect(ValueSliderView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView ValueSliderView, MouseTrackingView, defaultOpts(), ->

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      vsv = setupVSV value: 20
      vsv.$el.css 'margin', 20

      # don't destroy vsv after test block
      vsvs = []

      # add to the DOM to see how it looks
      $player.append vsv.el


  xdescribe 'ValueSliderView: thorough tests', ->
