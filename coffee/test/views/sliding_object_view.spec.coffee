goog.provide 'acorn.specs.views.SlidingObjectView'

goog.require 'acorn.player.SlidingObjectView'
goog.require 'acorn.player.MouseTrackingView'

describe 'acorn.player.SlidingObjectView', ->

  SlidingObjectView = acorn.player.SlidingObjectView
  MouseTrackingView = acorn.player.MouseTrackingView
  EventSpy = athena.lib.util.test.EventSpy

  util = athena.lib.util
  test = util.test


  defaultOpts = ->
    eventhub: _.extend {}, Backbone.Events

  sovs = []
  afterEach ->
    for sov in sovs
      sov.destroy()
    sovs = []

  # construct a new slider base view and receive pointers to the view and its
  # handle elements
  setupSOV = (opts) =>
    opts = _.defaults (opts ? {}), defaultOpts()
    sov = new SlidingObjectView opts
    sov.render()
    sovs.push sov
    object = sov.$ '.sliding-object'
    [sov, object]

  # $.css('left') malfunctions when not in DOM so test it indirectly
  getLeft = ($el) ->
    styles = $el.attr('style').split ';'

    left = ''
    for style in styles
      style = style.trim().split ': '
      if style[0] == 'left' then left = style[1]

    left


  it 'should be part of acorn.player', ->
    expect(SlidingObjectView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView SlidingObjectView, MouseTrackingView, defaultOpts(), ->

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      # add to the DOM to see how it looks
      [sov, object] = setupSOV location: 20

      container = $('<div>')
        .height(9)
        .css('margin', 20)
        .css('position', 'relative')
        .css('background-color', '#CCC')

      # make object pop out of its container
      object.height(15).width(15).css('top', -3)

      # more vivid colorscheme
      object.css 'background-color', '#555'

      # don't destroy sov after test block
      sovs = []

      # add to the DOM to see how it looks
      $player.append container.append sov.el


    describe 'SlidingObjectView: location', ->

      it 'should track a location value that defaults to 0', ->
        [sov, object] = setupSOV()
        expect(sov._location).toBe 0

      it 'should permit a custom location value through an option', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV location: location
          expect(sov._location).toBe location


      describe 'SlidingObjectView::location', ->

        it 'should be a method', ->
          [sov, object] = setupSOV()
          expect(typeof sov.location).toBe 'function'

        it 'should offer access to location value', ->
          locations = [20, 40, 60]

          for location in locations
            [sov, object] = setupSOV location: location
            expect(sov.location()).toBe location

        it 'should set location value', ->
          locations = [20, 40, 60]

          for location in locations
            [sov, object] = setupSOV()
            sov.location location
            expect(sov._location).toBe location

        it 'should bound location value between 0 and 100', ->
          locations = [-20, 140, 9001, -65536]

          for location in locations
            [sov, object] = setupSOV()
            sov.location location
            expectation = if location < 0 then 0 else 100
            expect(sov._location).toBe expectation

        it 'should not set location value from non-numbers', ->
          locations = ['20', x: 140, [9001], true]

          for location in locations
            [sov, object] = setupSOV()
            sov.location location
            expect(sov._location).toBe 0


    describe 'SlidingObjectView: sliding object', ->

      it 'should be a div wrapped in a div inside slidingObjectView.el', ->
        [sov, object] = setupSOV()

        padded = sov.$el.children 'div.padded-box'
        expect(padded.length).toBe 1

        slidingObject = padded.children 'div.sliding-object'
        expect(slidingObject.length).toBe 1
        expect(slidingObject[0]).toBe object[0]

      it 'should have its left css style default to 0%', ->
        [sov, object] = setupSOV()
        expect(getLeft object).toBe '0%'

      it 'should customize its left css style with its location option', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV location: location
          expect(getLeft object).toBe "#{location}%"

      it 'should update its left css style when location is changed', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV()
          sov.location location
          expect(getLeft object).toBe "#{location}%"


    describe 'SlidingObjectView: mouse handling', ->

      it 'should store location on mouse start', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV location: location

          # mousedown event
          mousedownEvent = jQuery.Event 'mousedown'
          mousedownEvent.which = 1
          mousedownEvent.pageX = 100
          mousedownEvent.pageY = 100

          # mousemove event
          mousemoveEvent = jQuery.Event 'mousemove'
          mousemoveEvent.pageX = 101
          mousemoveEvent.pageY = 100

          expect(sov._locationAtMouseStart).toBeUndefined

          object.trigger mousedownEvent
          expect(sov._locationAtMouseStart).toBeUndefined

          $(document).trigger mousemoveEvent
          expect(sov._locationAtMouseStart).toBe location

          sov.destroy()

      it 'should throw away stored location on mouse stop', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV location: location

          # mousedown event
          mousedownEvent = jQuery.Event 'mousedown'
          mousedownEvent.which = 1
          mousedownEvent.pageX = 100
          mousedownEvent.pageY = 100

          # mousemove event
          mousemoveEvent = jQuery.Event 'mousemove'
          mousemoveEvent.pageX = 101
          mousemoveEvent.pageY = 100

          # mouseup event
          mouseupEvent = jQuery.Event 'mouseup'
          mouseupEvent.pageX = 101
          mouseupEvent.pageY = 100

          expect(sov._locationAtMouseStart).toBeUndefined

          object.trigger mousedownEvent
          expect(sov._locationAtMouseStart).toBeUndefined

          $(document).trigger mousemoveEvent
          expect(sov._locationAtMouseStart).toBe location

          object.trigger mouseupEvent
          expect(sov._locationAtMouseStart).toBeUndefined

          sov.destroy()

      it 'should update location on drag', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV location: location
          sov.$el.width(100).css 'position', 'relative'

          $player = $('<div>').addClass('acorn-player').width(600).height(400)
              .appendTo('body')
          $player.append sov.el
          @after -> $player.remove()

          # mousedown event
          mousedownEvent = jQuery.Event 'mousedown'
          mousedownEvent.which = 1
          mousedownEvent.pageX = location
          mousedownEvent.pageY = 100

          # mousemove event
          mousemoveEvent = (x) ->
            e = jQuery.Event 'mousemove'
            e.pageX = x
            e.pageY = 100
            e

          expect(sov.location()).toBe location

          object.trigger mousedownEvent
          expect(sov.location()).toBe location

          $(document).trigger mousemoveEvent 35
          expect(sov.location()).toBe 35

          $(document).trigger mousemoveEvent location + 20
          expect(sov.location()).toBe location + 20

          sov.destroy()


    describe 'SlidingObjectView: events', ->

      it 'should fire \'DidChangeLocation\' event when location changes', ->
        locations = [20, 40, 60]

        for location in locations
          [sov, object] = setupSOV()
          spy = new EventSpy sov, 'SlidingObjectView:DidChangeLocation'

          expect(spy.triggered).toBe false
          sov.location location
          expect(spy.triggered).toBe true
          expect(spy.arguments[0]).toEqual [location]
