goog.provide 'acorn.specs.shells.VideoLinkShell'

goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.LinkShell'
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

        it 'should display total playback time', ->
          options = viewOptions()
          options.model.set 'timeStart', 35
          options.model.set 'timeEnd', 122

          rv = new RemixView options
          rv.render()

          totalTime = rv.$ '.total-time'

          expect(totalTime.length).toBe 1
          expect(totalTime.text()).toBe timestring 122 - 35

        describe 'start time and end time input fields', ->

          # helper to check time start and end input fields and model data
          expectTimes = (rv, start, end) ->
            expect(rv.$('input.start.time-field').val()).toBe(timestring start)
            expect(rv.$('input.end.time-field').val()).toBe(timestring end)
            expect(rv.model.get 'timeStart').toBe start
            expect(rv.model.get 'timeEnd').toBe end

          it 'should exist', ->
            rv = new RemixView viewOptions()
            rv.render()

            expect(rv.$('input.start.time-field').length).toBe 1
            expect(rv.$('input.end.time-field').length).toBe 1

          it 'should contain correct values from model data on render', ->
            times = [
              {start: 0, end: 300}
              {start: 0, end: 212}
              {start: 50, end: 300}
              {start: 23, end: 55}
              {start: 240, end: 274}
            ]

            test = (start, end) ->
              options = viewOptions()
              options.model.set 'timeStart', start
              options.model.set 'timeEnd', end

              rv = new RemixView options
              rv.render()
              expectTimes rv, start, end

            test(t.start, t.end) for t in times

          it 'should update display values on both change and blur', ->
            rv = new RemixView viewOptions()
            rv.render()

            startInput = rv.$ 'input.start.time-field'
            endInput = rv.$ 'input.end.time-field'

            time = 5
            for property, input of {timeStart: startInput, timeEnd: endInput}
              for event in ['change', 'blur']
                # use unique n each round
                thisTime = time++
                input.val thisTime
                expect(Number(input.val())).toBe thisTime
                input[event]()
                expect(input.val()).toBe timestring thisTime

          it 'should update model values on both change and blur', ->
            rv = new RemixView viewOptions()
            rv.render()

            startInput = rv.$ 'input.start.time-field'
            endInput = rv.$ 'input.end.time-field'

            time = 5
            for property, input of {timeStart: startInput, timeEnd: endInput}
              for event in ['change', 'blur']
                # use unique n each round
                thisTime = time++
                input.val thisTime
                expect(rv.model.get property).not.toBe thisTime
                input[event]()
                expect(rv.model.get property).toBe thisTime

          it 'should accept numbers and timestrings and ignore bad values', ->
            rv = new RemixView viewOptions()
            rv.render()

            startInput = rv.$ 'input.start.time-field'
            endInput = rv.$ 'input.end.time-field'

            # setup, confirm background assumptions
            startInput.val 20
            endInput.val 50
            startInput.change()
            expectTimes rv, 20, 50

            startInput.val '40'
            endInput.val '#75'
            startInput.change()
            expectTimes rv, 40, 50

            startInput.val '13m9s'
            endInput.val 'forty-five'
            startInput.change()
            expectTimes rv, 13, 50

            startInput.val 'add-ten'
            endInput.val '2:08'
            startInput.change()
            expectTimes rv, 13, 128

            startInput.val '01:12'
            endInput.val '213'
            startInput.change()
            expectTimes rv, 72, 213

          it 'should enforce video start and end as boundaries', ->
            rv = new RemixView viewOptions()
            rv.render()

            startInput = rv.$ 'input.start.time-field'
            endInput = rv.$ 'input.end.time-field'

            # setup, confirm background assumptions
            startInput.val 20
            endInput.val 50
            startInput.change()
            expectTimes rv, 20, 50

            # test that start is truncated at 0
            startInput.val -23
            startInput.change()
            expectTimes rv, 0, 50

            startInput.val 23
            startInput.change()
            expectTimes rv, 23, 50
            startInput.val '-2:09'
            startInput.change()
            expectTimes rv, 0, 50

            # test that end is truncated at timeTotal
            rv.model.set 'timeTotal', 100
            startInput.val 0
            endInput.val 90
            endInput.change()
            expectTimes rv, 0, 90

            endInput.val 120
            endInput.change()
            expectTimes rv, 0, 100

            rv.model.set 'timeTotal', 150
            endInput.val 120
            endInput.change()
            expectTimes rv, 0, 120

            rv.model.set 'timeTotal', 80
            endInput.change()
            expectTimes rv, 0, 80

          it 'should enforce start time before end time', ->
            rv = new RemixView viewOptions()
            rv.render()

            startInput = rv.$ 'input.start.time-field'
            endInput = rv.$ 'input.end.time-field'

            # setup, confirm background assumptions
            startInput.val 20
            endInput.val 50
            startInput.change()
            expectTimes rv, 20, 50

            # should lock whichever input changed and adjust the other
            startInput.val '1:10'
            endInput.val 50
            startInput.change()
            expectTimes rv, 70, 80

            startInput.val '1:10'
            endInput.val 50
            endInput.change()
            expectTimes rv, 40, 50

            # should truncate against lower and upper bounds (0 and totalTime)
            totalTime = rv.model.get 'timeTotal'

            startInput.val totalTime - 5
            endInput.val 5
            startInput.change()
            expectTimes rv, totalTime - 5, totalTime

            startInput.val totalTime - 5
            endInput.val 5
            endInput.change()
            expectTimes rv, 0, 5

          it 'should display error colors when offered inverted times', ->
            expectError = (start, end, error) ->
              rv = new RemixView viewOptions()
              rv.render()

              startInput = rv.$ 'input.start.time-field'
              endInput = rv.$ 'input.end.time-field'
              inputControls = rv.$ '.control-group.time-field'

              # error is added after call stack clears, so test asynchronously
              clearedCallStack = false

              runs ->
                startInput.val start
                endInput.val end
                startInput.change()
                setTimeout (-> clearedCallStack = true), 0

              waitsFor (-> clearedCallStack), 'call stack to clear', 100

              runs ->
                for control in inputControls
                  expect($(control).hasClass('error')).toBe error

            times = [
              {start: 30, end: 20, error: true}
              {start: 90, end: 12, error: true}
              {start: 23, end: 55, error: false}
              {start: 150, end: 130, error: true}
              {start: 240, end: 274, error: false}
            ]

            expectError(t.start, t.end, t.error) for t in times

          it 'should update total time display on changes', ->
            rv = new RemixView viewOptions()
            rv.render()

            startInput = rv.$ 'input.start.time-field'
            endInput = rv.$ 'input.end.time-field'
            totalTime = rv.$ '.total-time'

            times = [
              {start: 20, end: 30}
              {start: 90, end: 125}
              {start: 23, end: 55}
              {start: 9, end: 130}
              {start: 0, end: 274}
            ]

            for t in times
              startInput.val t.start
              endInput.val t.end
              startInput.change()
              expect(totalTime.text()).toBe timestring(t.end - t.start)


        # TODO: range slider test. waiting on range slider implementation
        describe 'RemixView slider', ->

          it '------ NOT IMPLEMENTED ------ range slider', ->


      describe 'looping: RemixView', ->

        it 'should have 3 loops buttons in html, only one of which should ' +
            'ever be shown', ->
          rv = new RemixView viewOptions()
          rv.render()

          expect(rv.$('button.loops').length).toBe 3
          _.each rv.$('button.loops'), (button) ->
            expect($(button).html()).toBe 'loops:'

          loopsDivs = rv.$ 'div.loops'

          hidden = 0
          for div in loopsDivs
            hidden++ if $(div).hasClass 'hidden'
          expect(hidden).toBe 2

        it 'should cycle through loops buttons on click', ->
          rv = new RemixView viewOptions()
          rv.render()

          loopsDivs = rv.$ 'div.loops'

          # cycle through loops buttons via clicks, recording which is shown
          shownDivs = for i in [1..3]
            hidden = 0
            shown = undefined

            for div in loopsDivs
              if $(div).hasClass 'hidden'
                hidden++
              else
                shown = div

            expect(hidden).toBe 2
            $(shown).find('button').click()
            shown

          for div in loopsDivs
            expect(_.contains shownDivs, div).toBe true

        it 'should display correct loops button on render', ->
          rv = new RemixView viewOptions()
          rv.render()

          expect(rv.$('div.loops.one-loops').hasClass 'hidden').toBe false
          expect(rv.$('div.loops.infinity-loops').hasClass 'hidden').toBe true
          expect(rv.$('div.loops.n-loops').hasClass 'hidden').toBe true

          options = viewOptions()
          options.model.set 'loops', 'infinity'
          rv = new RemixView options
          rv.render()

          expect(rv.$('div.loops.one-loops').hasClass 'hidden').toBe true
          expect(rv.$('div.loops.infinity-loops').hasClass 'hidden').toBe false
          expect(rv.$('div.loops.n-loops').hasClass 'hidden').toBe true

          options = viewOptions()
          options.model.set 'loops', 4
          rv = new RemixView options
          rv.render()

          expect(rv.$('div.loops.one-loops').hasClass 'hidden').toBe true
          expect(rv.$('div.loops.infinity-loops').hasClass 'hidden').toBe true
          expect(rv.$('div.loops.n-loops').hasClass 'hidden').toBe false

        it 'should have an `nLoops` method that tracks custom looping value', ->
          rv = new RemixView viewOptions()

          # default value: 2
          expect(rv.nLoops()).toBe 2

          rv.nLoops 3
          expect(rv.nLoops()).toBe 3
          expect(rv.nLoops 5).toBe 5

        it 'should reset to previous n-loops value upon returning to n-loops ' +
            'mode', ->
          options = viewOptions()
          options.model.set 'loops', 4
          rv = new RemixView options
          rv.render()

          nLoopsDiv = rv.$ 'div.loops.n-loops'

          # confirm expectations
          expect(nLoopsDiv.hasClass 'hidden').toBe false
          expect(Number nLoopsDiv.find('input').val()).toBe 4

          # convince view that n-loops value is 6
          rv.nLoops 6

          # cycle once through loops buttons
          button = $ rv.$('button.loops')[0]
          for i in [1..3]
            button.click()
            expect(nLoopsDiv.hasClass 'hidden').toBe i != 3

          # expect loops-n value to have been changed
          expect(Number nLoopsDiv.find('input').val()).toBe 6

        it 'should react well to changes to the custom loops text field', ->
          options = viewOptions()
          options.model.set 'loops', 4
          rv = new RemixView options
          rv.render()

          nLoopsDiv = rv.$ 'div.loops.n-loops'
          input = nLoopsDiv.find 'input'

          # confirm expectations
          expect(nLoopsDiv.hasClass 'hidden').toBe false
          expect(Number nLoopsDiv.find('input').val()).toBe 4

          # view should react to input.change and input.blur
          n = 5
          for event in ['change', 'blur']
            # use unique n each round
            thisN = n++
            input.val thisN
            expect(rv.model.get 'loops').not.toBe thisN
            input[event]()
            expect(rv.model.get 'loops').toBe thisN
            expect(Number input.val()).toBe thisN

          # expect valid values to be accepted and invalid values rejected
          validValues = [2, 0, '1', 5.3, 8, '2.392', 234]
          invalidValues = [-1, 'walrus', -0.2, '!23']

          for value in validValues
            input.val value
            expect(rv.model.get 'loops').not.toBe Math.floor value
            input.change()
            expect(rv.model.get 'loops').toBe Math.floor value
            expect(Number input.val()).toBe Math.floor value

          validValue = nLoopsDiv.find('input').val()
          for value in invalidValues
            input.val value
            input.change()
            expect(rv.model.get 'loops').toBe Number validValue
            expect(input.val()).toBe validValue


      it 'should look good', ->
        # setup DOM
        acorn.util.appendCss()
        $player = $('<div>').addClass('acorn-player').width(600).height(400)
            .appendTo('body')

        # add a SplashView into the DOM to see how it looks.
        view = new RemixView viewOptions()
        view.render()
        $player.append view.el
