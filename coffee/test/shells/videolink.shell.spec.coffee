goog.provide 'acorn.specs.shells.VideoLinkShell'

goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.player.TimeRangeInputView'
goog.require 'acorn.player.CycleButtonView'
goog.require 'acorn.util.test'

describe 'acorn.shells.VideoLinkShell', ->
  VideoLinkShell = acorn.shells.VideoLinkShell

  it 'should be part of acorn.shells', ->
    expect(VideoLinkShell).toBeDefined()

  acorn.util.test.describeShellModule VideoLinkShell, ->

    Model = VideoLinkShell.Model
    MediaView = VideoLinkShell.MediaView
    RemixView = VideoLinkShell.RemixView

    timestring = acorn.util.Time.secondsToTimestring
    viewOptions = -> model: new Model(timeTotal: 300)

    validLinks = VideoLinkShell.validLinkPatterns
    expectLinkMatches = (link) ->
      expect(acorn.shells.LinkShell.linkMatches link, validLinks).toBe true

    it 'should recognize .avi video links', ->
      expectLinkMatches 'http://www.example.com/rgb256.avi'

    it 'should recognize .mov video links', ->
      expectLinkMatches 'www.example.org/rgb256.mov'

    it 'should recognize .wmv video links', ->
      expectLinkMatches 'http://example.ai/rgb256.wmv'


    describe 'VideoLinkShell.Model', ->

      model = new Model {link: 'http://video.com/video.mov', loops: 2}

      it 'should have a duration method that returns a number', ->
        expect(typeof model.duration()).toBe 'number'


    describe 'VideoLinkShell.MediaView', ->

      it 'should create a Timer instance on initialize', ->
        mv = new MediaView viewOptions()
        expect(mv.timer instanceof acorn.util.Timer).toBe true

      # TODO: test onPlaybackTick. waiting on integration with video start,
      # pause, and seek calls
      it '------ NOT TESTED ------ should enforce start time', ->
      it '------ NOT TESTED ------ should enforce end time', ->
      it '------ NOT TESTED ------ should loop correctly', ->

      # TODO: visual test. waiting on ability to embed video links
      it '------ NOT IMPLEMENTED ------ should look good', ->


    describe 'VideoLinkShell.RemixView', ->

      describe 'time management: RemixView', ->

        it 'should create a timeRangeInputView', ->
          rv = new RemixView viewOptions()
          TimeRangeInputView = acorn.player.TimeRangeInputView
          expect(rv._timeRangeInputView instanceof TimeRangeInputView).toBe true

        it 'should initialize timeRangeInputView with start and end times', ->
          times = [
            {start: 0, end: 300}
            {start: 0, end: 212}
            {start: 50, end: 300}
            {start: 23, end: 55}
            {start: 240, end: 274}
          ]

          for t in times
            options = viewOptions()
            options.model.set 'timeStart', t.start
            options.model.set 'timeEnd', t.end

            rv = new RemixView options
            rv.render()
            triv = rv._timeRangeInputView

            expect(triv.values().start).toBe t.start
            expect(triv.values().end).toBe t.end

        it 'should update model values when timeRangeInputView changes', ->
          rv = new RemixView viewOptions()
          rv.render()

          triv = rv._timeRangeInputView
          inputs =
            timeStart: triv.startInputView
            timeEnd: triv.endInputView

          times = [
            {timeStart: 0, timeEnd: 300}
            {timeStart: 0, timeEnd: 212}
            {timeStart: 50, timeEnd: 300}
            {timeStart: 23, timeEnd: 55}
            {timeStart: 240, timeEnd: 274}
          ]

          for t in times
            for property, time of t
              inputs[property].value time
              expect(rv.model.get property).toBe time


      describe 'looping: RemixView', ->

        it 'should build a loops button from a CycleButtonView', ->
          rv = new RemixView viewOptions()
          CycleButtonView = acorn.player.CycleButtonView
          expect(rv._loopsButtonView instanceof CycleButtonView).toBe true

        it 'should initialize loops button with correct elements', ->
          rv = new RemixView viewOptions()
          rv.render()
          views = rv._loopsButtonView.views

          # 3 views
          expect(views.length).toBe 3

          # name 'loops:'
          _.each views, (view) ->
            expect(view.find('button').html()).toBe 'loops:'

          # only the last view should be an input view
          expect(views[0].find('input').length).toBe 0
          expect(views[1].find('input').length).toBe 0
          expect(views[2].find('input').length).toBe 1

          # static buttons should have values 1 and ∞
          expect(views[0].find('.static-value').text()).toBe '1'
          expect(views[1].find('.static-value').text()).toBe '∞'

        it 'should initialize loops button with current state', ->
          states = [
            {loops: 'one', view: 0, name: 'one', value: '1'}
            {loops: 'infinity', view: 1, name: 'infinity', value: '∞'}
            {loops: '3', view: 2, name: 'n', value: '3'}
            {loops: undefined, view: 0, name: 'one', value: '1'}
          ]

          for state in states
            options = viewOptions()
            options.model.set 'loops', state.loops

            rv = new RemixView options
            rv.render()
            lbv = rv._loopsButtonView
            lbvState = lbv.currentState()

            expect(lbvState.view).toBe lbv.views[state.view]
            expect(lbvState.name).toBe state.name
            expect(lbvState.value).toBe state.value

        it 'should update model values when loops button cycles', ->
          rv = new RemixView viewOptions()
          rv.render()
          lbv = rv._loopsButtonView

          lbv.showView 0
          expect(rv.model.get 'loops').toBe 'one'

          lbv.showView 1
          expect(rv.model.get 'loops').toBe 'infinity'

          lbv.showView 2
          expect(rv.model.get 'loops').toBe '2'

        it 'should update model values when loops input button changes', ->
          rv = new RemixView viewOptions()
          rv.render()
          lbv = rv._loopsButtonView
          input = lbv.views[2].find 'input'

          # confirm background expectations
          lbv.showView 2
          expect(rv.model.get 'loops').toBe '2'

          input.val 1
          input.change()
          expect(rv.model.get 'loops').toBe '1'

          input.val 3.92
          input.change()
          expect(rv.model.get 'loops').toBe '3'

          input.val '9'
          input.blur()
          expect(rv.model.get 'loops').toBe '9'


      it 'should look good', ->
        # setup DOM
        acorn.util.appendCss()
        $player = $('<div>').addClass('acorn-player').width(600).height(400)
            .appendTo('body')

        # add a SplashView into the DOM to see how it looks.
        view = new RemixView viewOptions()
        view.render()
        $player.append view.el
