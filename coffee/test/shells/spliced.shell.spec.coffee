goog.provide 'acorn.specs.shells.SplicedShell'

goog.require 'acorn.shells.SplicedShell'
goog.require 'acorn.player.Player'
goog.require 'acorn.util.test'

describe 'acorn.shells.SplicedShell', ->
  SplicedShell = acorn.shells.SplicedShell

  Model = SplicedShell.Model
  MediaView = SplicedShell.MediaView
  RemixView = SplicedShell.RemixView

  viewOptions = ->
    model: new Model
    eventhub: _.extend {}, Backbone.Events

  view = undefined
  afterEach ->
    view?.remove?()

  it 'should be part of acorn.shells', ->
    expect(SplicedShell).toBeDefined()

  acorn.util.test.describeShellModule SplicedShell, ->

    describe 'SplicedShell.MediaView', ->

      describe 'MediaView::controlsView', ->

        it 'should have a play button', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          playControl = view.controlsView.$ '.control-view.play'
          expect(playControl.length).toBe 1

        it 'should have a play button that is initially hidden', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          playControl = view.controlsView.$ '.control-view.play'
          expect(playControl.length).toBe 1
          expect(playControl.hasClass 'hidden').toBe true

        it 'should have a pause button', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          pauseControl = view.controlsView.$ '.control-view.pause'
          expect(pauseControl.length).toBe 1

        it 'should have a pause button that is not initially hidden', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          pauseControl = view.controlsView.$ '.control-view.pause'
          expect(pauseControl.length).toBe 1
          expect(pauseControl.hasClass 'hidden').toBe false

        it 'should show play button when paused', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          view.pause()
          expect(view.isPaused()).toBe true

          playControl = view.controlsView.$ '.control-view.play'
          expect(playControl.hasClass 'hidden').toBe false

        it 'should hide pause button when paused', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          view.pause()
          expect(view.isPaused()).toBe true

          pauseControl = view.controlsView.$ '.control-view.pause'
          expect(pauseControl.hasClass 'hidden').toBe true

        it 'should hide play button when playing', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          expect(view.isPlaying()).toBe true

          playControl = view.controlsView.$ '.control-view.play'
          expect(playControl.hasClass 'hidden').toBe true

        it 'should show pause button when playing', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          expect(view.isPlaying()).toBe true

          pauseControl = view.controlsView.$ '.control-view.pause'
          expect(pauseControl.hasClass 'hidden').toBe false

        it 'should play when play button is clicked', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          playControl = view.controlsView.$ '.control-view.play'
          view.pause()

          spyOn view, 'play'
          playControl.click()
          expect(view.play).toHaveBeenCalled()

        it 'should pause when pause button is clicked', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.play()
          pauseControl = view.controlsView.$ '.control-view.pause'

          spyOn view, 'pause'
          pauseControl.click()
          expect(view.pause).toHaveBeenCalled()

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
