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
          view.play()

          spyOn view, 'showNext'
          expect(view.showNext.callCount).toBe 0

          jasmine.Clock.tick(4999)
          expect(view.showNext.callCount).toBe 0

          jasmine.Clock.tick(2)
          expect(view.showNext.callCount).toBe 1


      # TODO - properly determine when youtube has loaded in order to test this
        xit 'should cycle to next shell after shell duration when shell duration
            is finite but more than delay', ->
          # set delay and shells
          _viewOptions = viewOptions()
          m = _viewOptions.model
          m.delay 5
          m.set 'shells', [{
            timeTotal: 571,
            timeEnd: 571,
            timeStart: 560,
            shellid: "acorn.YouTubeShell",
            link: "https://www.youtube.com/watch?v=yYAw79386WI",
            loops: "one"
            # or try:
            # shellid: "acorn.VimeoShell"
            # link: 'http://www.vimeo.com/8201078'
          }, {
            link: "https://www.video.com/video.avi"
            loops: "one"
            shellid: "acorn.VideoLinkShell"
            timeTotal: 10
          }]

          view = new MediaView _viewOptions
          ready = undefined
          jasmine.Clock.useMock()

          runs ->
            # setup DOM
            acorn.util.appendCss()
            $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
                .height(400).appendTo('body')

            # must be appended to DOM in order for youtubeShell to load properly
            view.controlsView.render()
            $hiddenPlayer.append view.render().el
            view.shellViews[0].playerView.on 'PlayerView:Ready', -> ready = true

          waitsFor (-> ready), 'video player to be ready', 10000

          runs ->
            spyOn view, 'showNext'
            expect(view.showNext.callCount).toBe 0

            jasmine.Clock.tick(9910999)
            expect(view.showNext.callCount).toBe 0

            jasmine.Clock.tick(2)
            expect(view.showNext.callCount).toBe 1

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
          view.play()

          spyOn view, 'showNext'
          expect(view.showNext.callCount).toBe 0

          jasmine.Clock.tick(4999)
          expect(view.showNext.callCount).toBe 0

          jasmine.Clock.tick(2)
          expect(view.showNext.callCount).toBe 1


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
