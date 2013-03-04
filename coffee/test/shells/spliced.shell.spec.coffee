goog.provide 'acorn.specs.shells.SplicedShell'

goog.require 'acorn.shells.SplicedShell'
goog.require 'acorn.player.Player'
goog.require 'acorn.util.test'

describe 'acorn.shells.SplicedShell', ->
  Shell = acorn.shells.Shell
  SplicedShell = acorn.shells.SplicedShell

  Model = SplicedShell.Model
  MediaView = SplicedShell.MediaView
  RemixView = SplicedShell.RemixView

  modelOptions = ->
    shellid: SplicedShell.id
    shells: [
      {shellid: Shell.id}
      {shellid: Shell.id}
    ]

  viewOptions = ->
    model: new Model modelOptions()
    eventhub: _.extend {}, Backbone.Events

  view = undefined
  afterEach ->
    view?.remove?()

  it 'should be part of acorn.shells', ->
    expect(SplicedShell).toBeDefined()

  acorn.util.test.describeShellModule SplicedShell, modelOptions(), ->

    describe 'SplicedShell.MediaView', ->

      describe 'MediaView::controlsView', ->

        describe 'MediaView::playPauseToggleView', ->

          it 'should get created', ->
            view = new MediaView viewOptions()
            Toggle = acorn.player.controls.PlayPauseControlToggleView
            expect(view.playPauseToggleView instanceof Toggle).toBe true

          it 'should get added to controlsView', ->
            view = new MediaView viewOptions()
            expect(_.contains view.controlsView.buttons,
                view.playPauseToggleView).toBe true

          it 'should get refreshed when media plays', ->
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            toggle = view.playPauseToggleView
            spyOn toggle, 'refreshToggle'

            expect(toggle.refreshToggle).not.toHaveBeenCalled()
            view.setMediaState 'play'
            expect(toggle.refreshToggle).toHaveBeenCalled()

          it 'should get refreshed when media pauses', ->
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            toggle = view.playPauseToggleView
            spyOn toggle, 'refreshToggle'

            expect(toggle.refreshToggle).not.toHaveBeenCalled()
            view.setMediaState 'pause'
            expect(toggle.refreshToggle).toHaveBeenCalled()

          it 'should get refreshed when media ends', ->
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            toggle = view.playPauseToggleView
            spyOn toggle, 'refreshToggle'

            expect(toggle.refreshToggle).not.toHaveBeenCalled()
            view.setMediaState 'end'
            expect(toggle.refreshToggle).toHaveBeenCalled()

          it 'should play mediaView when play button is clicked', ->
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            view.play()
            playControl = view.controlsView.$ '.control-view.play'
            view.pause()

            spyOn view, 'play'
            playControl.click()
            expect(view.play).toHaveBeenCalled()

          it 'should pause mediaView when pause button is clicked', ->
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            view.play()
            pauseControl = view.controlsView.$ '.control-view.pause'

            spyOn view, 'pause'
            pauseControl.click()
            expect(view.pause).toHaveBeenCalled()


        describe 'MediaView::elapsedTimeView', ->

          it 'should have an elapsed time control', ->
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            view.play()
            elapsedTimeControl = view.controlsView.$ '.elapsed-time-control-view'
            expect(elapsedTimeControl.length).toBe 1

          it 'should call seek when elapsed time control seeks', ->
            spyOn MediaView::, 'seek'
            view = new MediaView viewOptions()
            view.controlsView.render()
            view.render()
            view.play()
            elapsedTimeControl = view.controlsView.$ '.elapsed-time-control-view'
            seekField = elapsedTimeControl.find 'input'

            expect(MediaView::seek).not.toHaveBeenCalled()

            for offset in [0, 10, 20, 30, 40, 50]
              seekField.val offset
              seekField.blur()
              expect(MediaView::seek).toHaveBeenCalled()
              expect(MediaView::seek).toHaveBeenCalledWith offset


      test.describeDefaults SplicedShell.MediaView, {
        playOnReady: true
        subshellPlayOnReady: false
        showSubshellControls: false
        showSubshellSummary: false
        autoAdvanceOnEnd: true
      }, viewOptions()


      describe 'MediaView::progressBarState', ->

        it 'should return an object with showing: false when duration is
            Infinity', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn Infinity

          expect(view.progressBarState().showing).toBe false

        it 'should return an object with showing: true when duration is not
            Infinity', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 50

          expect(view.progressBarState().showing).toBe true

        it 'should return an object with progress set to percentProgress when
            duration is not Infinity', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 50
          spyOn(view, 'percentProgress').andReturn 'fakeValue'

          expect(view.progressBarState().progress).toBe 'fakeValue'


      describe 'MediaView::_onProgressBarDidProgress', ->

        it 'should make a call to progressFromPercent', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 80
          spyOn(view, 'seekOffset').andReturn 10
          spyOn(view, 'progressFromPercent').andReturn 10

          expect(view.progressFromPercent).not.toHaveBeenCalled()
          view._onProgressBarDidProgress 20
          expect(view.progressFromPercent).toHaveBeenCalled()

        it 'should make a call to progressFromPercent', ->
          view = new MediaView viewOptions()
          spyOn(view, 'duration').andReturn 80
          spyOn(view, 'seekOffset').andReturn 10
          spyOn view, 'seek'

          view._onProgressBarDidProgress 0
          expect(view.seek.mostRecentCall.args[0]).toBe 0

          view._onProgressBarDidProgress 25
          expect(view.seek.mostRecentCall.args[0]).toBe 20

          view._onProgressBarDidProgress 50
          expect(view.seek.mostRecentCall.args[0]).toBe 40

          view._onProgressBarDidProgress 75
          expect(view.seek.mostRecentCall.args[0]).toBe 60

          view._onProgressBarDidProgress 100
          expect(view.seek.mostRecentCall.args[0]).toBe 80


      describe 'MediaView: events', ->

        it 'should update progress bar on Media:Progress event', ->
          spyOn MediaView::, '_updateProgressBar'
          view = new MediaView viewOptions()

          expect(MediaView::_updateProgressBar).not.toHaveBeenCalled()
          view.trigger 'Media:Progress'
          expect(MediaView::_updateProgressBar).toHaveBeenCalled()


    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      # add to the DOM to see how it looks
      m = acorn.Model.withShellData {
        shellid: 'acorn.SplicedShell'
        shells: [{
          link: "https://www.youtube.com/watch?v=yYAw79386WI"
          loops: "one"
          shellid: "acorn.YouTubeShell"
          timeTotal: 571
        }, {
          link: "https://www.youtube.com/watch?v=yYAw79386WI"
          loops: "one"
          shellid: "acorn.YouTubeShell"
          timeTotal: 571
        }]
      }

      m.acornid 'notnew'

      player = new acorn.player.Player
        eventhub: @eventhub
        model: m
        editable: true

      player.render()
      player.appendTo $player


    describe 'CollectionShell.RemixView', ->

      describe 'RemixView::defaultAttributes', ->

        it 'should default title to the title of its first subshell', ->
          rv = new RemixView viewOptions()

          fakeShells = new Backbone.Collection()
          for i in [0..2]
            fakeShell = new Backbone.Model()
            fakeShell.title = -> 'A Fake Title'
            fakeShell.thumbnail = -> 'thumbnails.com/fake.jpg'
            fakeShells.add fakeShell

          spyOn(rv.model, 'shells').andReturn fakeShells
          rv._updateAttributesWithDefaults()
          expect(rv.model.title()).toBe 'A Fake Title'
