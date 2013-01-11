goog.provide 'acorn.specs.views.TimeRangeInputView'

goog.require 'acorn.player.TimeInputView'
goog.require 'acorn.player.TimeRangeInputView'

describe 'acorn.player.TimeRangeInputView', ->
  TimeRangeInputView = acorn.player.TimeRangeInputView

  it 'should be part of acorn.player', ->
    expect(TimeRangeInputView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView TimeRangeInputView, athena.lib.View, ->

    timestring = acorn.util.Time.secondsToTimestring

    # construct a new time range input view and receive pointers to the view and
    # an object containing its widgets
    setupTRIV = (opts) ->
      triv = new TimeRangeInputView opts
      triv.render()

      widgets =
        startInputView: triv.startInputView
        endInputView: triv.endInputView
        slider: triv.$ '.time-slider'
        totalTime: triv.$ '.total-time'

      [triv, widgets]

    it 'should contain a rangeslider, a total-time field, and start and end ' +
        'time input views', ->
      [triv, widgets] = setupTRIV()
      TimeInputView = acorn.player.TimeInputView

      expect(triv).toBeDefined()
      expect(widgets.startInputView instanceof TimeInputView).toBe true
      expect(widgets.endInputView instanceof TimeInputView).toBe true
      expect(widgets.slider.length).toBe 1
      expect(widgets.totalTime.length).toBe 1

    it 'should accept initialization values and provide read/write access ' +
        'through a `values` property', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      expect(triv.values().start).toBe 0
      expect(triv.values().end).toBe 50

      triv.values start: 25
      expect(triv.values().start).toBe 25
      expect(triv.values().end).toBe 50

      triv.values end: 35
      expect(triv.values().start).toBe 25
      expect(triv.values().end).toBe 35

      triv.values {start: 10, end: 40}
      expect(triv.values().start).toBe 10
      expect(triv.values().end).toBe 40

    it 'should propagate values to its time inputs and rangeslider', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      expect(widgets.startInputView.value()).toBe 0
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 0
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      triv.values {start: 10, end: 40}
      expect(widgets.startInputView.value()).toBe 10
      expect(widgets.endInputView.value()).toBe 40
      expect(widgets.slider.rangeslider('values')[0]).toBe 10
      expect(widgets.slider.rangeslider('values')[1]).toBe 40

    it 'should abide by min and max restrictions', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50
        min: 0
        max: 100

      # confirm background assumptions
      expect(widgets.startInputView.value()).toBe 0
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 0
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      triv.values {start: 10, end: 140}
      expect(widgets.startInputView.value()).toBe 10
      expect(widgets.endInputView.value()).toBe 100
      expect(widgets.slider.rangeslider('values')[0]).toBe 10
      expect(widgets.slider.rangeslider('values')[1]).toBe 100

      triv.values {start: -40, end: 60}
      expect(widgets.startInputView.value()).toBe 0
      expect(widgets.endInputView.value()).toBe 60
      expect(widgets.slider.rangeslider('values')[0]).toBe 0
      expect(widgets.slider.rangeslider('values')[1]).toBe 60

    it 'should propagate setMin and setMax to its widgets', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50
        min: 0
        max: 100

      # confirm background assumptions
      expect(widgets.startInputView.value()).toBe 0
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 0
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      triv.setMin 20
      expect(widgets.startInputView.value()).toBe 20
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 20
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      triv.setMax 35
      expect(widgets.startInputView.value()).toBe 20
      expect(widgets.endInputView.value()).toBe 35
      expect(widgets.slider.rangeslider('values')[0]).toBe 20
      expect(widgets.slider.rangeslider('values')[1]).toBe 35

      # expect values to stay at upper and lower bounds when individual widgets
      # are given values that exceed these bounds
      widgets.startInputView.value 10
      widgets.endInputView.value 60
      widgets.slider.rangeslider 'values', [0, 45]
      expect(widgets.startInputView.value()).toBe 20
      expect(widgets.endInputView.value()).toBe 35
      expect(widgets.slider.rangeslider('values')[0]).toBe 20
      expect(widgets.slider.rangeslider('values')[1]).toBe 35

    it 'should fire events correctly on _change', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      endInput = widgets.endInputView.$ 'input'
      startInput = widgets.startInputView.$ 'input'

      spies =
        startSpy: new athena.lib.util.test.EventSpy triv, 'change:start'
        endSpy: new athena.lib.util.test.EventSpy triv, 'change:end'
        timesSpy: new athena.lib.util.test.EventSpy triv, 'change:times'

      setTimeFns = [
        ->
          previous = triv.values()
          triv.values start: 10
          expectations =
            startSpy: 10
            timesSpy: {start: 10, end: previous.end}
        ->
          previous = triv.values()
          endInput.val 60
          endInput.change()
          expectations =
            endSpy: 60
            timesSpy: {start: previous.start, end: 60}
        ->
          previous = triv.values()
          triv.values {start: 20, end: 70}
          expectations =
            startSpy: 20
            endSpy: 70
            timesSpy: {start: 20, end: 70}
        ->
          previous = triv.values()
          startInput.val 30
          startInput.change()
          endInput.val 80
          endInput.change()
          expectations =
            startSpy: 30
            endSpy: 80
            timesSpy: {start: 30, end: 80}
        ->
          previous = triv.values()
          triv.values previous
          undefined
        ->
          previous = triv.values()
          startInput.val previous.start
          startInput.change()
          {}
      ]

      athena.lib.util.test.expectEventSpyBehaviors spies, setTimeFns

    it 'should handle changes to input fields and keep all inputs in sync', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      # confirm background assumptions
      expect(widgets.startInputView.value()).toBe 0
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 0
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      # change start input field
      widgets.startInputView.$('input').val 20
      widgets.startInputView.$('input').change()
      expect(widgets.startInputView.value()).toBe 20
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 20
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      # change end input field
      widgets.endInputView.$('input').val 40
      widgets.endInputView.$('input').change()
      expect(widgets.startInputView.value()).toBe 20
      expect(widgets.endInputView.value()).toBe 40
      expect(widgets.slider.rangeslider('values')[0]).toBe 20
      expect(widgets.slider.rangeslider('values')[1]).toBe 40

    it '------ TODO ------
        should handle changes to range slider and keep all inputs in sync', ->
      # Slider widget should get refactored into a view. Until then, there is no
      # easy way to programatically cause the slider to announce changes.

    it 'should enforce start time before end time, bouncing the appropriate time
        input when they cross', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      # confirm background assumptions
      expect(widgets.startInputView.value()).toBe 0
      expect(widgets.endInputView.value()).toBe 50
      expect(widgets.slider.rangeslider('values')[0]).toBe 0
      expect(widgets.slider.rangeslider('values')[1]).toBe 50

      # change start input field
      widgets.startInputView.$('input').val 80
      widgets.startInputView.$('input').change()
      expect(widgets.startInputView.value()).toBe 80
      expect(widgets.endInputView.value()).toBe 90
      expect(widgets.slider.rangeslider('values')[0]).toBe 80
      expect(widgets.slider.rangeslider('values')[1]).toBe 90

      # change end input field
      widgets.endInputView.$('input').val 40
      widgets.endInputView.$('input').change()
      expect(widgets.startInputView.value()).toBe 30
      expect(widgets.endInputView.value()).toBe 40
      expect(widgets.slider.rangeslider('values')[0]).toBe 30
      expect(widgets.slider.rangeslider('values')[1]).toBe 40

    it 'should manage total time', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      expect(widgets.totalTime.text()).toBe timestring 50

      triv.values {start: 10, end: 40}
      expect(widgets.totalTime.text()).toBe timestring 30

      widgets.endInputView.value 30
      expect(widgets.totalTime.text()).toBe timestring 20

      triv.values {start: 20}
      expect(widgets.totalTime.text()).toBe timestring 10

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
          .appendTo('body')

      # add a SplashView into the DOM to see how it looks.
      [triv, widgets] = setupTRIV
        start: 0
        end: 50
        min: 0
        max: 100
      $player.append triv.el

