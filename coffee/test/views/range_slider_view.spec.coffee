goog.provide 'acorn.specs.views.RangeSliderView'

goog.require 'acorn.player.RangeSliderView'
goog.require 'acorn.player.SlidingObjectView'

describe 'acorn.player.RangeSliderView', ->

  RangeSliderView = acorn.player.RangeSliderView
  MouseTrackingView = acorn.player.MouseTrackingView
  EventSpy = athena.lib.util.test.EventSpy

  util = athena.lib.util
  test = util.test

  xdescribe = test.xdescribe


  defaultOpts = ->
    eventhub: _.extend {}, Backbone.Events

  rsvs = []
  afterEach ->
    for rsv in rsvs
      rsv.destroy()
    rsvs = []

  # construct a new slider base view and receive pointers to the view and its
  # handle elements
  setupRSV = (opts) =>
    opts = _.defaults (opts ? {}), defaultOpts()
    rsv = new RangeSliderView opts
    rsv.render()
    rsvs.push rsv
    rsv


  it 'should be part of acorn.player', ->
    expect(RangeSliderView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView RangeSliderView, MouseTrackingView, defaultOpts(), ->

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      rsv = setupRSV low: 20, high: 60
      rsv.$el.css 'margin', 20

      # don't destroy rsv after test block
      rsvs = []

      # add to the DOM to see how it looks
      $player.append rsv.el


  xdescribe 'RangeSliderView: thorough tests', ->
