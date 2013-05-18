goog.provide 'acorn.specs.views.TimeRangeInputView'

goog.require 'acorn.player.RangeSliderView'
goog.require 'acorn.player.ProgressRangeSliderView'
goog.require 'acorn.player.TimeInputView'
goog.require 'acorn.player.TimeRangeInputView'

describe 'acorn.player.TimeRangeInputView', ->
  RangeSliderView = acorn.player.RangeSliderView
  TimeRangeInputView = acorn.player.TimeRangeInputView

  EventSpy = athena.lib.util.test.EventSpy

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
        rangeSliderView: triv.rangeSliderView
        startInputView: triv.startInputView
        totalInputView: triv.totalInputView
        endInputView: triv.endInputView

      [triv, widgets]


    describe 'TimeRangeInputView: default values', ->

      it 'should default min and max values to 0 and Infinity', ->
        [triv, widgets] = setupTRIV()

        expect(triv._min).toBe 0
        expect(triv._max).toBe Infinity

      it 'should default start and end values to min and max values', ->
        [triv, widgets] = setupTRIV
          min: 30
          max: 80

        expect(triv._start).toBe 30
        expect(triv._end).toBe 80

      it 'should default progress value to start value', ->
        [triv, widgets] = setupTRIV
          start: 40

        expect(triv._progress).toBe 40

      it 'should default bounce offset to 10', ->
        [triv, widgets] = setupTRIV
          start: 40

        expect(triv._bounceOffset).toBe 10

      it 'should default slider view class to ProgressRangeSliderView', ->
        [triv, widgets] = setupTRIV
          start: 40

        expect(triv.rangeSliderView instanceof
            acorn.player.ProgressRangeSliderView).toBe true


    it 'should contain a range slider view, and start, total,
        end time input views', ->
      [triv, widgets] = setupTRIV()
      TimeInputView = acorn.player.TimeInputView

      expect(triv).toBeDefined()
      expect(widgets.rangeSliderView instanceof RangeSliderView).toBe true
      expect(widgets.startInputView instanceof TimeInputView).toBe true
      expect(widgets.totalInputView instanceof TimeInputView).toBe true
      expect(widgets.endInputView instanceof TimeInputView).toBe true


    describe 'TimeRangeInputView::values', ->

      it 'should provide read access to start and end through a `values`
          property', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        expect(triv.values().start).toBe 0
        expect(triv.values().end).toBe 50

        triv._start = 25
        expect(triv.values().start).toBe 25
        expect(triv.values().end).toBe 50

        triv._end= 35
        expect(triv.values().start).toBe 25
        expect(triv.values().end).toBe 35

        triv._start = 10
        triv._end = 40
        expect(triv.values().start).toBe 10
        expect(triv.values().end).toBe 40

      it 'should provide write access to start and end through a `values`
          property', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        expect(triv.values().start).toBe 0
        expect(triv.values().end).toBe 50
        expect(triv._start).toBe 0
        expect(triv._end).toBe 50

        triv.values start: 25
        expect(triv.values().start).toBe 25
        expect(triv.values().end).toBe 50
        expect(triv._start).toBe 25
        expect(triv._end).toBe 50

        triv.values end: 35
        expect(triv.values().start).toBe 25
        expect(triv.values().end).toBe 35
        expect(triv._start).toBe 25
        expect(triv._end).toBe 35

        triv.values {start: 10, end: 40}
        expect(triv.values().start).toBe 10
        expect(triv.values().end).toBe 40
        expect(triv._start).toBe 10
        expect(triv._end).toBe 40

      it 'should propagate values to its range slider and time inputs', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          max: 100

        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 50
        expect(widgets.startInputView.value()).toBe 0
        expect(widgets.endInputView.value()).toBe 50

        triv.values {start: 10, end: 40}
        expect(widgets.rangeSliderView.values()[0]).toBe 10
        expect(widgets.rangeSliderView.values()[1]).toBe 40
        expect(widgets.startInputView.value()).toBe 10
        expect(widgets.endInputView.value()).toBe 40

      it 'should update its range slider\'s progress percentage', ->
        [triv, widgets] = setupTRIV
          start: 0
          progress: 20
          end: 50
          max: 100

        expect(widgets.rangeSliderView.progress()).toBe 40

        triv.values start: 10
        expect(widgets.rangeSliderView.progress()).toBe 25

        triv.values end: 40
        expect(widgets.rangeSliderView.progress()).toBe 1 / 3 * 100


    describe 'TimeRangeInputView::progress', ->

      it 'should provide read access to progress value', ->
        [triv, widgets] = setupTRIV
          start: 0
          progress: 20
          end: 50

        expect(triv.progress()).toBe 20
        expect(triv._progress).toBe 20

        triv.progress 30
        expect(triv.progress()).toBe 30
        expect(triv._progress).toBe 30

      it 'should provide write access to progress value', ->
        [triv, widgets] = setupTRIV
          start: 0
          progress: 20
          end: 50

        expect(triv.progress()).toBe 20

        triv._progress = 30
        expect(triv.progress()).toBe 30

      it 'should update its range slider\'s progress percentage', ->
        [triv, widgets] = setupTRIV
          start: 0
          progress: 20
          end: 50
          max: 100

        expect(widgets.rangeSliderView.progress()).toBe 40

        triv.progress 30
        expect(widgets.rangeSliderView.progress()).toBe 60


    describe 'TimeRangeInputView: min and max', ->

      it 'should abide by min and max restrictions', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          min: 0
          max: 100

        # confirm background assumptions
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 50
        expect(widgets.startInputView.value()).toBe 0
        expect(widgets.endInputView.value()).toBe 50

        triv.values {start: 10, end: 140}
        expect(widgets.rangeSliderView.values()[0]).toBe 10
        expect(widgets.rangeSliderView.values()[1]).toBe 100
        expect(widgets.startInputView.value()).toBe 10
        expect(widgets.endInputView.value()).toBe 100

        triv.values {start: -40, end: 60}
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 60
        expect(widgets.startInputView.value()).toBe 0
        expect(widgets.endInputView.value()).toBe 60

      it 'should propagate setMin and setMax to its widgets', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          min: 0
          max: 100

        # confirm background assumptions
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 50
        expect(widgets.startInputView.value()).toBe 0
        expect(widgets.endInputView.value()).toBe 50

        triv.setMin 20
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 30*100/80
        expect(widgets.startInputView.value()).toBe 20
        expect(widgets.endInputView.value()).toBe 50

        triv.setMax 35
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 100
        expect(widgets.startInputView.value()).toBe 20
        expect(widgets.endInputView.value()).toBe 35

        # expect values to stay at upper and lower bounds when individual widgets
        # are given values that exceed these bounds
        widgets.startInputView.value 10
        widgets.endInputView.value 60
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.rangeSliderView.values()[1]).toBe 100
        expect(widgets.startInputView.value()).toBe 20
        expect(widgets.endInputView.value()).toBe 35


    describe 'TimeRangeInputView: start and end inputs', ->

      it 'should handle changes to start input field and keep all inputs in
          sync', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          max: 100

        # confirm background assumptions
        expect(widgets.rangeSliderView.values()[0]).toBe 0
        expect(widgets.startInputView.value()).toBe 0

        # change start input field
        widgets.startInputView.$('input').val 20
        widgets.startInputView.$('input').change()
        expect(widgets.rangeSliderView.values()[0]).toBe 20
        expect(widgets.startInputView.value()).toBe 20

      it 'should handle changes to end input field and keep all inputs in sync',
          ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          max: 100

        # confirm background assumptions
        expect(widgets.rangeSliderView.values()[1]).toBe 50
        expect(widgets.endInputView.value()).toBe 50

        # change end input field
        widgets.endInputView.$('input').val 40
        widgets.endInputView.$('input').change()
        expect(widgets.rangeSliderView.values()[1]).toBe 40
        expect(widgets.endInputView.value()).toBe 40


      describe 'TimeRangeInputView: enforce start time before end time', ->

        it 'should bounce end input above start input when start crosses end', ->
          [triv, widgets] = setupTRIV
            start: 0
            end: 50
            max: 100

          # confirm background assumptions
          expect(widgets.startInputView.value()).toBe 0
          expect(widgets.endInputView.value()).toBe 50
          expect(widgets.rangeSliderView.values()[0]).toBe 0
          expect(widgets.rangeSliderView.values()[1]).toBe 50

          # change start input field
          widgets.startInputView.$('input').val 80
          widgets.startInputView.$('input').change()
          expect(widgets.rangeSliderView.values()[0]).toBe 80
          expect(widgets.rangeSliderView.values()[1]).toBe 90
          expect(widgets.startInputView.value()).toBe 80
          expect(widgets.endInputView.value()).toBe 90

        it 'should bounce start input below end input when end crosses start', ->
          [triv, widgets] = setupTRIV
            start: 50
            end: 100
            max: 100

          # confirm background assumptions
          expect(widgets.startInputView.value()).toBe 50
          expect(widgets.endInputView.value()).toBe 100
          expect(widgets.rangeSliderView.values()[0]).toBe 50
          expect(widgets.rangeSliderView.values()[1]).toBe 100

          # change end input field
          widgets.endInputView.$('input').val 40
          widgets.endInputView.$('input').change()
          expect(widgets.rangeSliderView.values()[0]).toBe 30
          expect(widgets.rangeSliderView.values()[1]).toBe 40
          expect(widgets.startInputView.value()).toBe 30
          expect(widgets.endInputView.value()).toBe 40


    it 'should manage total time', ->
      [triv, widgets] = setupTRIV
        start: 0
        end: 50

      expect(widgets.totalInputView.value()).toBe 50

      triv.values {start: 10, end: 40}
      expect(widgets.totalInputView.value()).toBe 30

      widgets.endInputView.value 30
      expect(widgets.totalInputView.value()).toBe 20

      triv.values {start: 20}
      expect(widgets.totalInputView.value()).toBe 10


    describe 'TimeRangeInputView: events', ->

      it 'should respond to rangeSliderView\'s LowValueDidChange event', ->
        spy = spyOn TimeRangeInputView::, '_onRangeSliderLowValueDidChange'
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        expect(spy).not.toHaveBeenCalled()
        triv.rangeSliderView.trigger 'RangeSliderView:LowValueDidChange'
        expect(spy).toHaveBeenCalled()

      it 'should respond to rangeSliderView\'s HighValueDidChange event', ->
        spy = spyOn TimeRangeInputView::, '_onRangeSliderHighValueDidChange'
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        expect(spy).not.toHaveBeenCalled()
        triv.rangeSliderView.trigger 'RangeSliderView:HighValueDidChange'
        expect(spy).toHaveBeenCalled()

      it 'should respond to rangeSliderView\'s ProgressDidChange event', ->
        spy = spyOn TimeRangeInputView::, '_onRangeSliderProgressDidChange'
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        expect(spy).not.toHaveBeenCalled()
        triv.rangeSliderView.trigger 'ProgressRangeSliderView:ProgressDidChange'
        expect(spy).toHaveBeenCalled()

      it 'should update start on rangeSliderView\'s LowValueDidChange event', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          max: 80

        expect(triv.values().start).toBe 0

        # change start to 25% between min and max
        triv.rangeSliderView.trigger 'RangeSliderView:LowValueDidChange', 25
        expect(triv.values().start).toBe 20

      it 'should update end on rangeSliderView\'s HighValueDidChange event', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50
          max: 80

        expect(triv.values().end).toBe 50

        # change end to 37.5% between min and max
        triv.rangeSliderView.trigger 'RangeSliderView:HighValueDidChange', 37.5
        expect(triv.values().end).toBe 30

      it 'should update progress on rangeSliderView\'s ProgressDidChange event',
          ->
        [triv, widgets] = setupTRIV
          start: 0
          progress: 20
          end: 50

        expect(triv.progress()).toBe 20

        # change progress to 60% between start and end
        triv.rangeSliderView.trigger 'ProgressRangeSliderView:' +
            'ProgressDidChange', 60
        expect(triv.progress()).toBe 30

      it 'should fire TimeRangeInputView:DidChangeStart when start value
          changes', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        startSpy = new EventSpy triv, 'TimeRangeInputView:DidChangeStart'

        expect(startSpy.triggerCount).toBe 0
        triv.values start: 10
        expect(startSpy.triggerCount).toBe 1
        expect(startSpy.arguments[0][0]).toBe 10

      it 'should fire TimeRangeInputView:DidChangeEnd when end value
          changes', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        endSpy = new EventSpy triv, 'TimeRangeInputView:DidChangeEnd'

        expect(endSpy.triggerCount).toBe 0
        triv.values end: 10
        expect(endSpy.triggerCount).toBe 1
        expect(endSpy.arguments[0][0]).toBe 10

      it 'should fire TimeRangeInputView:DidChangeTimes when start value
          changes', ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        timesSpy = new EventSpy triv, 'TimeRangeInputView:DidChangeTimes'

        expect(timesSpy.triggerCount).toBe 0
        triv.values start: 10
        expect(timesSpy.triggerCount).toBe 1
        expect(timesSpy.arguments[0][0].start).toBe 10
        expect(timesSpy.arguments[0][0].end).toBe 50

      it 'should fire TimeRangeInputView:DidChangeTimes when end value changes',
          ->
        [triv, widgets] = setupTRIV
          start: 0
          end: 50

        timesSpy = new EventSpy triv, 'TimeRangeInputView:DidChangeTimes'

        expect(timesSpy.triggerCount).toBe 0
        triv.values end: 10
        expect(timesSpy.triggerCount).toBe 1
        expect(timesSpy.arguments[0][0].start).toBe 0
        expect(timesSpy.arguments[0][0].end).toBe 10

      it 'should fire TimeRangeInputView:DidChangeProgress when progress value
          changes', ->
        [triv, widgets] = setupTRIV
          start: 0
          progress: 10
          end: 50

        progressSpy = new EventSpy triv, 'TimeRangeInputView:DidChangeProgress'

        expect(progressSpy.triggerCount).toBe 0
        triv.progress 30
        expect(progressSpy.triggerCount).toBe 1
        expect(progressSpy.arguments[0][0]).toBe 30


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
        progress: 30

      $player.append triv.$el.css 'margin-top', 20

