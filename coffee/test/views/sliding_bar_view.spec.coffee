goog.provide 'acorn.specs.views.SlidingBarView'

goog.require 'acorn.player.SlidingBarView'
goog.require 'acorn.player.SlidingObjectView'

describe 'acorn.player.SlidingBarView', ->

  SlidingBarView = acorn.player.SlidingBarView
  SlidingObjectView = acorn.player.SlidingObjectView
  EventSpy = athena.lib.util.test.EventSpy

  util = athena.lib.util
  test = util.test


  defaultOpts = ->
    eventhub: _.extend {}, Backbone.Events

  sbvs = []
  afterEach ->
    for sbv in sbvs
      sbv.destroy()
    sbvs = []

  # construct a new slider base view and receive pointers to the view and its
  # handle elements
  setupSBV = (opts) =>
    opts = _.defaults (opts ? {}), defaultOpts()
    sbv = new SlidingBarView opts
    sbv.render()
    sbvs.push sbv
    bar = sbv.$ '.sliding-bar'
    [sbv, bar]

  # get array of element styles
  # $.css('left') malfunctions when not in DOM so test it indirectly
  getLeftAndRight = ($el) ->
    styles = $el.attr('style').split ';'

    left = right = ''
    for style in styles
      style = style.trim().split ': '
      if style[0] == 'left' then left = style[1]
      if style[0] == 'right' then right = style[1]

    [left, right]


  it 'should be part of acorn.player', ->
    expect(SlidingBarView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView SlidingBarView, SlidingObjectView, defaultOpts(), ->

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      [innerSBV, bar] = setupSBV low: 20, high: 60
      [sbv, bar] = setupSBV low: 20, high: 60, internalViews: [innerSBV]

      innerSBV._slidingObject.height(10).css 'background-color', '#AAA'
      sbv._slidingObject.height 10

      container = $('<div>')
        .height(10)
        .css('margin', 20)
        .css('position', 'relative')
        .css('background-color', '#DDD')

      # don't destroy sbv after test block
      sbvs = []

      # add to the DOM to see how it looks
      $player.append container.append sbv.el


    describe 'SlidingBarView: values', ->

      it 'should disable location method (converting it into a no-op)', ->
        [sbv, bar] = setupSBV()
        expect(typeof sbv.location).toBe 'function'
        expect(sbv.location()).toBeUndefined()
        expect(sbv._location).toBeUndefined()

      it 'should track low and high values that default to 0 and 100', ->
        [sbv, bar] = setupSBV()
        expect(sbv._low).toBe 0
        expect(sbv._high).toBe 100

      it 'should permit custom low and high values through options', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV values
          expect(sbv._low).toBe values.low ? 0
          expect(sbv._high).toBe values.high ? 100

      describe 'SlidingBarView::values', ->

        it 'should be a method', ->
          [sbv, bar] = setupSBV()
          expect(typeof sbv.values).toBe 'function'

        it 'should offer access to low and high values', ->
          valuesArray = [
            {}
            {low: 20, high: 30}
            {high: 80}
            {low: 40}
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV values

            expect(sbv.values().low).toBe values.low ? 0
            expect(sbv.values().high).toBe values.high ? 100

        it 'should set low and high values from an object', ->
          valuesArray = [
            {low: 20, high: 30}
            {high: 80}
            {low: 40}
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV()

            sbv.values values
            expect(sbv._low).toBe values.low ? 0
            expect(sbv._high).toBe values.high ? 100

        it 'should set low and high values from an array', ->
          valuesArray = [
            [20, 30]
            [80, 90]
            [10, 70]
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV()

            sbv.values values
            expect(sbv._low).toBe values[0]
            expect(sbv._high).toBe values[1]

        it 'should not set values when given an array with only one element', ->
          valuesArray = [
            [20]
            [40]
            [60]
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV()

            sbv.values values
            expect(sbv._low).toBe 0
            expect(sbv._high).toBe 100

        it 'should correctly match low and high values when given an array',
            ->
          valuesArray = [
            [20, 30]
            [40, 30]
            [80, 90]
            [80, 30]
            [10, 70]
            [90, 70]
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV()

            lowIndex = if values[0] < values[1] then 0 else 1

            sbv.values values
            expect(sbv._low).toBe values[lowIndex]
            expect(sbv._high).toBe values[1 - lowIndex]

        it 'should enforce low value as low when given an object', ->
          valuesArray = [
            {low: 50, high: 30}
            {low: 95, high: 80}
            {low: 40, high: 10}
          ]

          for {low, high} in valuesArray
            [sbv, bar] = setupSBV()

            sbv.values high: high
            expect(sbv._high).toBe high

            sbv.values low: low
            expect(sbv._low).toBe low
            expect(sbv._high).toBe low

        it 'should enforce high value as high when given an object', ->
          valuesArray = [
            {low: 50, high: 30}
            {low: 95, high: 80}
            {low: 40, high: 10}
          ]

          for {low, high} in valuesArray
            [sbv, bar] = setupSBV()

            sbv.values low: low
            expect(sbv._low).toBe low

            sbv.values high: high
            expect(sbv._high).toBe high
            expect(sbv._low).toBe high

        it 'should bound values between 0 and 100', ->
          valuesArray = [
            {low: -40, high: -30}
            {low: 520, high: 830}
            {high: -80}
            {low: 240}
            {low: 20, high: 130}
            {low: -20, high: 80}
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV()

            low = values.low ? 0
            high = values.high ? 100
            low = if low < 0 then 0 else if low > 100 then 100 else low
            high = if high < 0 then 0 else if high > 100 then 100 else high

            sbv.values values
            expect(sbv._low).toBe low
            expect(sbv._high).toBe high

        it 'should not set values from non-numbers', ->
          valuesArray = [
            {low: '340', high: 30}
            {low: 50, high: '30'}
            {high: [80]}
            {low: low: 40}
            {low: false, high: true}
            {low: '20', high: '-80'}
          ]

          for values in valuesArray
            [sbv, bar] = setupSBV()

            low = if _.isNumber values.low then values.low else 0
            high = if _.isNumber values.high then values.high else 100

            sbv.values values
            expect(sbv._low).toBe low
            expect(sbv._high).toBe high


    describe 'SlidingBarView: sliding bar', ->

      it 'should be a div with class .sliding-bar inside slidingBarView.el', ->
        [sbv, bar] = setupSBV()

        slidingBar = sbv.$el.children 'div.sliding-bar'
        expect(slidingBar.length).toBe 1
        expect(slidingBar[0]).toBe bar[0]

      it 'should contain a div.internal-views inside div.sliding-bar', ->
        [sbv, bar] = setupSBV()
        expect(bar.children('div.internal-views').length).toBe 1

      it 'should append an internal view passed in as an option', ->
        class InternalView extends Backbone.View
          className: 'internal-view'
          render: =>
            super
            @$el.empty()
            @$el.append @options.content
            @

        ivs = [
          new InternalView content: $('<div>').addClass 'iv0'
          new InternalView content: $('<div>').addClass 'iv1'
          new InternalView content: $('<div>').addClass 'iv2'
          new InternalView content: $('<div>').addClass 'iv3'
        ]

        for iv, i in ivs
          [sbv, bar] = setupSBV internalViews: [iv]
          internalViews = sbv.$ '.internal-views'

          expect(sbv.internalViews.length).toBe 1
          expect(internalViews.children().length).toBe 1
          expect(internalViews.find(".iv#{i}").length).toBe 1

      it 'should append multiple internal views passed in as options', ->
        class InternalView extends Backbone.View
          className: 'internal-view'
          render: =>
            super
            @$el.empty()
            @$el.append @options.content
            @

        ivs = [
          new InternalView content: $('<div>').addClass 'iv0'
          new InternalView content: $('<div>').addClass 'iv1'
          new InternalView content: $('<div>').addClass 'iv2'
          new InternalView content: $('<div>').addClass 'iv3'
        ]

        ivSets = [
          [ivs[0], ivs[1]]
          [ivs[1], ivs[2], ivs[3]]
          [ivs[0], ivs[1], ivs[2], ivs[3]]
        ]

        for ivs in ivSets
          [sbv, bar] = setupSBV internalViews: ivs
          internalViews = sbv.$ '.internal-views'
          expect(internalViews.children().length).toBe ivs.length

      it 'should have left and right css styles that default to 0%', ->
        [sbv, bar] = setupSBV()

        [left, right] = getLeftAndRight bar
        expect(left).toBe '0%'
        expect(right).toBe '0%'

      it 'should have left and right css styles that default to 0%', ->
        [sbv, bar] = setupSBV()

        [left, right] = getLeftAndRight bar
        expect(left).toBe '0%'
        expect(right).toBe '0%'

      it 'should use custom left and right styles from low and high options', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV values

          [left, right] = getLeftAndRight bar
          _left = values.low ? 0
          _right = 100 - (values.high ? 100)

          expect(left).toBe "#{_left}%"
          expect(right).toBe "#{_right}%"

      it 'should update left and right styles when values are changed', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV()
          sbv.values values

          [left, right] = getLeftAndRight bar
          _left = values.low ? 0
          _right = 100 - (values.high ? 100)

          expect(left).toBe "#{_left}%"
          expect(right).toBe "#{_right}%"


    describe 'SlidingBarView: mouse handling', ->

      it 'should store values on mouse start', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV _.clone values
          values = _.defaults values, low: 0, high: 100

          # mousedown event
          mousedownEvent = jQuery.Event 'mousedown'
          mousedownEvent.which = 1
          mousedownEvent.pageX = 100
          mousedownEvent.pageY = 100

          # mousemove event
          mousemoveEvent = jQuery.Event 'mousemove'
          mousemoveEvent.pageX = 101
          mousemoveEvent.pageY = 100

          expect(sbv._valuesAtMouseStart).toBeUndefined

          bar.trigger mousedownEvent
          expect(sbv._valuesAtMouseStart).toBeUndefined

          $(document).trigger mousemoveEvent
          expect(sbv._valuesAtMouseStart).toEqual values

          sbv.destroy()

      it 'should throw away stored values on mouse stop', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV _.clone values
          values = _.defaults values, low: 0, high: 100

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

          expect(sbv._valuesAtMouseStart).toBeUndefined

          bar.trigger mousedownEvent
          expect(sbv._valuesAtMouseStart).toBeUndefined

          $(document).trigger mousemoveEvent
          expect(sbv._valuesAtMouseStart).toEqual values

          bar.trigger mouseupEvent
          expect(sbv._valuesAtMouseStart).toBeUndefined

          sbv.destroy()

      it 'should update location on drag', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV _.clone values
          values = _.defaults values, low: 0, high: 100
          sbv.$el.width(100).css 'position', 'relative'

          $player = $('<div>').addClass('acorn-player').width(600).height(400)
              .appendTo('body')
          $player.append sbv.el
          @after -> $player.remove()

          # mousedown event
          mousedownEvent = jQuery.Event 'mousedown'
          mousedownEvent.which = 1
          mousedownEvent.pageX = values.high
          mousedownEvent.pageY = 100

          # mousemove event
          mousemoveEvent = (dx) ->
            e = jQuery.Event 'mousemove'
            e.pageX = values.high + dx
            e.pageY = 100
            e

          expectedValues = (dx = 0) ->
            low = values.low + dx
            high = values.high + dx
            adjustment =
              if low < 0 then 0 - low
              else if high > 100 then 100 - high
              else 0
            {low: low + adjustment, high: high + adjustment}

          expect(sbv.values()).toEqual values

          bar.trigger mousedownEvent
          expect(sbv.values()).toEqual values

          for dx in [-50, 5, -30, 50, 30, -5]
            $(document).trigger mousemoveEvent dx
            expect(sbv.values()).toEqual expectedValues dx

          sbv.destroy()


    describe 'SlidingBarView: events', ->

      it 'should fire \'DidChangeValues\' event when a value changes', ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV()
          spy = new EventSpy sbv, 'SlidingBarView:DidChangeValues'

          expect(spy.triggered).toBe false
          sbv.values values
          expect(spy.triggered).toBe true

          values = _.defaults values, low: 0, high: 100
          expect(spy.arguments[0]).toEqual [values]

      it "should fire 'DidChangeLowValue' event when a low value changes", ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV()
          spy = new EventSpy sbv, 'SlidingBarView:DidChangeLowValue'

          expect(spy.triggered).toBe false
          sbv.values values

          if values.low?
            expect(spy.triggered).toBe true
            expect(spy.arguments[0][0]).toBe values.low
          else
            expect(spy.triggered).toBe false

      it "should fire 'DidChangeHighValue' event when a high value changes", ->
        valuesArray = [
          {low: 20, high: 30}
          {high: 80}
          {low: 40}
        ]

        for values in valuesArray
          [sbv, bar] = setupSBV()
          spy = new EventSpy sbv, 'SlidingBarView:DidChangeHighValue'

          expect(spy.triggered).toBe false
          sbv.values values

          if values.high?
            expect(spy.triggered).toBe true
            expect(spy.arguments[0][0]).toBe values.high
          else
            expect(spy.triggered).toBe false
