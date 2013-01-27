goog.provide 'acorn.specs.views.ProgressRangeSliderView'

goog.require 'acorn.player.ProgressRangeSliderView'
goog.require 'acorn.player.RangeSliderView'

describe 'acorn.player.ProgressRangeSliderView', ->

  ProgressRangeSliderView = acorn.player.ProgressRangeSliderView
  RangeSliderView = acorn.player.RangeSliderView
  EventSpy = athena.lib.util.test.EventSpy

  util = athena.lib.util
  test = util.test

  xdescribe = test.xdescribe


  defaultOpts = ->
    eventhub: _.extend {}, Backbone.Events

  prsvs = []
  afterEach ->
    for prsv in prsvs
      prsv.destroy()
    prsvs = []

  # construct a new slider base view and receive pointers to the view and its
  # handle elements
  setupPRSV = (opts) =>
    opts = _.defaults (opts ? {}), defaultOpts()
    prsv = new ProgressRangeSliderView opts
    prsv.render()
    prsvs.push prsv
    prsv


  it 'should be part of acorn.player', ->
    expect(ProgressRangeSliderView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView ProgressRangeSliderView, RangeSliderView, defaultOpts(), ->

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      prsv = setupPRSV low: 20, high: 60, progress: 80
      prsv.$el.css 'margin', 20

      # don't destroy prsv after test block
      prsvs = []

      # add to the DOM to see how it looks
      $player.append prsv.el


  xdescribe 'ProgressRangeSliderView: thorough tests', ->
