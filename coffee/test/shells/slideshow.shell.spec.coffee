goog.provide 'acorn.specs.shells.SlideshowShell'

goog.require 'acorn.shells.SlideshowShell'
goog.require 'acorn.player.Player'
goog.require 'acorn.util.test'

describe 'acorn.shells.SlideshowShell', ->
  SlideshowShell = acorn.shells.SlideshowShell

  Model = SlideshowShell.Model
  MediaView = SlideshowShell.MediaView
  RemixView = SlideshowShell.RemixView

  viewOptions = ->
    model: new Model
    eventhub: _.extend {}, Backbone.Events

  view = undefined
  afterEach ->
    view?.remove?()

  it 'should be part of acorn.shells', ->
    expect(SlideshowShell).toBeDefined()

  acorn.util.test.describeShellModule SlideshowShell, ->


    describe 'SlideshowShell.MediaView', ->


      describe 'MediaView::isPlaying', ->

        it 'should by default be true on render', ->
          view = new MediaView viewOptions()
          view.render()
          expect(view.isPlaying()).toBe true

        it 'should be true following MediaView.play()', ->
          view = new MediaView viewOptions()
          view.render()
          view.play()
          expect(view.isPlaying()).toBe true

        it 'should be false following MediaView.pause()', ->
          view = new MediaView viewOptions()
          view.render()
          view.pause()
          expect(view.isPlaying()).toBe false


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
          playControl = view.controlsView.$ '.control-view.play'
          expect(playControl.length).toBe 1
          expect(playControl.hasClass 'hidden').toBe true

        it 'should have a pause button', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          pauseControl = view.controlsView.$ '.control-view.pause'
          expect(pauseControl.length).toBe 1

        it 'should have a pause button that is not initially hidden', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          pauseControl = view.controlsView.$ '.control-view.pause'
          expect(pauseControl.length).toBe 1
          expect(pauseControl.hasClass 'hidden').toBe false

        it 'should show play button when paused', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.pause()
          expect(view.isPlaying()).toBe false

          playControl = view.controlsView.$ '.control-view.play'
          expect(playControl.hasClass 'hidden').toBe false

        it 'should hide pause button when paused', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          view.pause()
          expect(view.isPlaying()).toBe false

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
          playControl = view.controlsView.$ '.control-view.play'

          view.pause()
          expect(view.isPlaying()).toBe false
          expect(playControl.hasClass 'hidden').toBe false

          playControl.click()
          expect(view.isPlaying()).toBe true
          expect(playControl.hasClass 'hidden').toBe true

        it 'should pause when pause button is clicked', ->
          view = new MediaView viewOptions()
          view.controlsView.render()
          view.render()
          pauseControl = view.controlsView.$ '.control-view.pause'

          view.play()
          expect(view.isPlaying()).toBe true
          expect(pauseControl.hasClass 'hidden').toBe false

          pauseControl.click()
          expect(view.isPlaying()).toBe false
          expect(pauseControl.hasClass 'hidden').toBe true


      describe 'MediaView playback', ->

        it 'should cycle to next shell after delay when shell duration is
            infinite', ->
          # set delay and shells
          _viewOptions = viewOptions()
          m = _viewOptions.model
          m.delay 5
          m.set 'shells', [{shellid: "acorn.Shell"}, {shellid: "acorn.Shell"}]

          jasmine.Clock.useMock()

          view = new MediaView _viewOptions
          view.controlsView.render()
          view.render()

          expect(view.currentIndex).toBe 0

          jasmine.Clock.tick(4999)
          expect(view.currentIndex).toBe 0

          jasmine.Clock.tick(2)
          expect(view.currentIndex).toBe 1


        it 'should cycle to next shell after shell duration when shell duration
            is finite but more than delay', ->
          # set delay and shells
          _viewOptions = viewOptions()
          m = _viewOptions.model
          m.delay 5
          m.set 'shells', [{
            link: "https://www.video.com/video.avi"
            loops: "one"
            shellid: "acorn.VideoLinkShell"
            timeTotal: 10
          }, {
            link: "https://www.video.com/video.avi"
            loops: "one"
            shellid: "acorn.VideoLinkShell"
            timeTotal: 10
          }]

          jasmine.Clock.useMock()

          view = new MediaView _viewOptions
          view.controlsView.render()
          view.render()

          expect(view.currentIndex).toBe 0

          jasmine.Clock.tick(9999)
          expect(view.currentIndex).toBe 0

          jasmine.Clock.tick(2)
          expect(view.currentIndex).toBe 1

        it 'should cycle to next shell after delay when shell duration is less
            than delay', ->
          # set delay and shells
          _viewOptions = viewOptions()
          m = _viewOptions.model
          m.delay 5
          m.set 'shells', [{
            link: "https://www.video.com/video.avi"
            loops: "one"
            shellid: "acorn.VideoLinkShell"
            timeTotal: 3
          }, {
            link: "https://www.video.com/video.avi"
            loops: "one"
            shellid: "acorn.VideoLinkShell"
            timeTotal: 3
          }]

          jasmine.Clock.useMock()

          view = new MediaView _viewOptions
          view.controlsView.render()
          view.render()

          expect(view.currentIndex).toBe 0

          jasmine.Clock.tick(4999)
          expect(view.currentIndex).toBe 0

          jasmine.Clock.tick(2)
          expect(view.currentIndex).toBe 1


    describe 'SlideshowShell.RemixView', ->

      it 'should have a time input view for setting the delay between slides',
          ->
        view = new RemixView viewOptions()
        view.render()
        expect(view.$('.slide-delay').length).toBe 1

      it 'should initialize time input view with current delay', ->
        _viewOptions = viewOptions()
        _viewOptions.model.delay 3
        view = new RemixView _viewOptions
        view.render()

        expect(view.$('.slide-delay').find('input').val()).toBe '3'

      it 'should save the slide delay to the model on enter', ->
        view = new RemixView viewOptions()
        view.render()
        expect(view.$('.slide-delay').length).toBe 1



    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      # add to the DOM to see how it looks
      m = acorn.Model.withShellData {
        shellid: 'acorn.SlideshowShell'
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
