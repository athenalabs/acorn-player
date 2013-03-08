goog.provide 'acorn.specs.shells.YouTubeShell'

goog.require 'acorn.shells.YouTubeShell'
goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.YouTubeShell', ->
  YouTubeShell = acorn.shells.YouTubeShell

  Model = YouTubeShell.Model
  MediaView = YouTubeShell.MediaView
  PlayerView = YouTubeShell.PlayerView
  RemixView = YouTubeShell.RemixView

  youtubeId = 'WgBeu3FVi60'
  videoLink = "http://www.youtube.com/watch?v=#{youtubeId}"

  modelOptions = ->
    link: videoLink
    timeStart: 33
    timeEnd: 145
    timeTotal: 300
    loops: 2

  viewOptions = ->
    model: new Model modelOptions()
    eventhub: _.extend {}, Backbone.Events

  it 'should be part of acorn.shells', ->
    expect(YouTubeShell).toBeDefined()

  acorn.util.test.describeShellModule YouTubeShell, modelOptions(), ->

    validLinks = YouTubeShell.validLinkPatterns
    expectLinkMatches = (link) ->
      expect(acorn.shells.LinkShell.linkMatches link, validLinks).toBe true


    describe 'YouTubeShell', ->

      it 'should recognize youtube.com/v/:id', ->
        expectLinkMatches "www.youtube.com/v/#{youtubeId}"

      it 'should recognize youtube.com/watch?v=:id', ->
        expectLinkMatches "http://www.youtube.com/watch?v=#{youtubeId}"

      it 'should recognize youtube.com/embed/:id', ->
        expectLinkMatches "http://www.youtube.com/embed/#{youtubeId}"

      it 'should recognize youtu.be/:id', ->
        expectLinkMatches "http://youtu.be/#{youtubeId}"

      it 'should recognize y2u.be/:id', ->
        expectLinkMatches "y2u.be/#{youtubeId}"

      it 'should recognize youtubelgoogleapis.com/v/:id', ->
        expectLinkMatches "http://youtube.googleapis.com/v/#{youtubeId}"


    describe 'YouTubeShell.Model', ->

      it 'should retrieve youtube id from url', ->
        urls = [
          "www.youtube.com/v/#{youtubeId}"
          "http://www.youtube.com/watch?v=#{youtubeId}"
          "http://www.youtube.com/embed/#{youtubeId}"
          "http://youtu.be/#{youtubeId}"
          "y2u.be/#{youtubeId}"
          "http://youtube.googleapis.com/v/#{youtubeId}"
        ]

        for url in urls
          model = new Model link: url
          expect(model.youtubeId()).toBe youtubeId

      it 'should have a valid metaDataUrl', ->
        model = new Model modelOptions()
        expect(model.metaDataUrl()).toBe "https://gdata.youtube.com/feeds/" +
            "api/videos/#{youtubeId}?v=2&alt=jsonc"


    describe 'YouTubeShell.PlayerView', ->
      it '------ TODO ------ make PlayerView tests work with PhantomJS', ->

    # TODO: most of these tests rely on in-DOM interaction with the youtube API
    # of a nature that phantomJS does not support. Although all of the following
    # tests pass when run with `grunt server`, all except the first fails when
    # run with `grunt test`
    xdescribe 'YouTubeShell.PlayerView', ->

      it 'should have a unique playerId', ->
        pvs = [
          new PlayerView viewOptions()
          new PlayerView viewOptions()
          new PlayerView viewOptions()
          new PlayerView viewOptions()
          new PlayerView viewOptions()
        ]

        for pv1 in pvs
          for pv2 in pvs
            unless pv1 == pv2
              expect(pv1.playerId()).not.toBe pv2.playerId()

      it 'should load a youtube player and cue the video on render', ->
        pv = new PlayerView viewOptions()

        # setup DOM
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')

        # must be appended to DOM in order to load properly
        runs -> $hiddenPlayer.append pv.render().el

        # ytPlayer.getPlayerState returns a non-negative integer value if video is
        # ended (0), playing (1), paused (2), buffering (3), or cued (5); any of
        # these corresponds to the player being ready with a cued/loaded video
        waitsFor (-> pv.player?.getPlayerState?()?), 'cued video', 10000
        runs ->
          pv.destroy()
          $hiddenPlayer.remove()


      it 'should announce state changes', ->
        pv = new PlayerView viewOptions()

        stateChanged = false
        pv.on 'Media:DidPlay', -> stateChanged = true

        # load player and cue video
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')

        runs -> $hiddenPlayer.append pv.render().el
        waitsFor (-> pv.player?.getPlayerState?()?), 'cued video', 10000

        runs -> pv.play()
        waitsFor (-> stateChanged), 'state change event', 10000
        runs ->
          pv.destroy()
          $hiddenPlayer.remove()


      describe 'PlayerView::_playbackIsAfterEnd', ->

        it 'should be a function', ->
          pv = new PlayerView viewOptions()
          expect(typeof pv._playbackIsAfterEnd).toBe 'function'

        it 'should return true when super returns true', ->
          _.each [23, 23.5, 24, 500], (offset, times) ->
            options = viewOptions()
            options.model.set 'timeEnd', 23
            pv = new PlayerView options
            expect(pv._playbackIsAfterEnd(offset)).toBe true

        it 'should by default return false when super returns false', ->
          _.each [0, 9, 9.9, 22, 22.9], (offset, times) ->
            options = viewOptions()
            options.model.set 'timeEnd', 23
            pv = new PlayerView options
            expect(pv._playbackIsAfterEnd(offset)).toBe false

        it 'should return true if player is in ended state', ->
          _.each [0, 9, 9.9, 22, 22.9], (offset, times) ->
            options = viewOptions()
            options.model.set 'timeEnd', 23
            pv = new PlayerView options

            # confirm background expectations
            expect(pv._playbackIsAfterEnd(offset)).toBe false

            pv._playerInEndedState = true
            expect(pv._playbackIsAfterEnd(offset)).toBe true


      describe 'video player view api', ->
        pv = undefined
        $hiddenPlayer = undefined

        beforeEach ->
          pv = new PlayerView viewOptions()

          # load player and cue video
          acorn.util.appendCss()
          $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
              .height(400).appendTo('body')
          runs -> $hiddenPlayer.append pv.render().el
          waitsFor (-> pv.player?.getPlayerState?()?), 'cued video', 10000

          # play video, wait for playing state
          runs -> pv.play()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PLAYING
          ), 'video to play', 10000

        afterEach ->
          pv.destroy()
          $hiddenPlayer.remove()

        it 'should play (yt api)', ->
          # pause video with youtube API, don't expect PLAYING state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() != YT.PlayerState.PLAYING
          ), 'video to pause with API', 10000

          # play video, expect PLAYING state
          runs -> pv.player.playVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PLAYING
          ), 'video to play after pausing', 10000

        it 'should play (media api)', ->
          # pause video with youtube API, don't expect PLAYING state
          runs -> pv.pause()
          waitsFor (->
            pv.player.getPlayerState() != YT.PlayerState.PLAYING
          ), 'video to pause with API', 10000

          # play video, expect PLAYING state
          runs -> pv.play()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PLAYING
          ), 'video to play after pausing', 10000

        it 'should pause (yt api)', ->
          # pause video, expect PAUSED state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause after playing', 10000

        it 'should pause (media api)', ->
          # pause video, expect PAUSED state
          runs -> pv.play()
          waitsFor (-> pv.isPlaying()), 'video should be playing', 10000

          runs -> pv.pause()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause after playing', 10000


        it 'should seek, both when playing and when paused', ->
          runs -> pv._seek 30
          waitsFor (->
            pv.player.getCurrentTime() == 30
          ), 'video to seek to 30 while playing', 10000

          runs -> pv._seek 40
          waitsFor (->
            pv.player.getCurrentTime() == 40
          ), 'video to seek to 40 while playing', 10000

          runs -> pv._seek 10
          waitsFor (->
            pv.player.getCurrentTime() == 10
          ), 'video to seek to 10 while playing', 10000

          runs -> pv._seek 20
          waitsFor (->
            pv.player.getCurrentTime() == 20
          ), 'video to seek to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause with API', 10000

          runs -> pv._seek 30
          waitsFor (->
            pv.player.getCurrentTime() == 30
          ), 'video to seek to 30 while paused', 10000

          runs -> pv._seek 40
          waitsFor (->
            pv.player.getCurrentTime() == 40
          ), 'video to seek to 40 while paused', 10000

          runs -> pv._seek 10
          waitsFor (->
            pv.player.getCurrentTime() == 10
          ), 'video to seek to 10 while paused', 10000

          runs -> pv._seek 20
          waitsFor (->
            pv.player.getCurrentTime() == 20
          ), 'video to seek to 20 while paused', 10000

        it 'should call `_monitorSeeking` on `_seek`', ->
          spyOn pv, '_monitorSeeking'
          expect(pv._monitorSeeking).not.toHaveBeenCalled()
          pv._seek 30
          expect(pv._monitorSeeking).toHaveBeenCalled()
          expect(pv._monitorSeeking).toHaveBeenCalledWith 30

        it 'should report whether or not it is playing', ->
          runs -> expect(pv.isPlaying()).toBe true

          # pause video, expect PAUSED state
          runs -> pv.pause()
          waitsFor (->
            not pv.isPlaying()
          ), 'playerView to register paused state', 10000

        it 'should report seek offset', ->
          opts = bypassMonitor: true

          runs -> pv.player.seekTo 30
          waitsFor (->
            pv._seekOffset(opts) == 30
          ), 'playerView to register _seekOffset to 30 while playing', 10000

          runs -> pv.player.seekTo 40
          waitsFor (->
            pv._seekOffset(opts) == 40
          ), 'playerView to register _seekOffset to 40 while playing', 10000

          runs -> pv.player.seekTo 10
          waitsFor (->
            pv._seekOffset(opts) == 10
          ), 'playerView to register _seekOffset to 10 while playing', 10000

          runs -> pv.player.seekTo 20
          waitsFor (->
            pv._seekOffset(opts) == 20
          ), 'playerView to register _seekOffset to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause with API', 10000

          runs -> pv.player.seekTo 30
          waitsFor (->
            pv._seekOffset(opts) == 30
          ), 'playerView to register _seekOffset to 30 while paused', 10000

          runs -> pv.player.seekTo 40
          waitsFor (->
            pv._seekOffset(opts) == 40
          ), 'playerView to register _seekOffset to 40 while paused', 10000

          runs -> pv.player.seekTo 10
          waitsFor (->
            pv._seekOffset(opts) == 10
          ), 'playerView to register _seekOffset to 10 while paused', 10000

          runs -> pv.player.seekTo 20
          waitsFor (->
            pv._seekOffset(opts) == 20
          ), 'playerView to register _seekOffset to 20 while paused', 10000

        it 'should report seek offset from seeking monitor if it is set', ->
          expect(pv._seekOffset()).not.toBe 'fakeOffset'
          pv._seekingMonitor?.destroy()
          pv._seekingMonitor = newOffset: 'fakeOffset', destroy: ->
          expect(pv._seekOffset()).toBe 'fakeOffset'


        describe 'PlayerView::_monitorSeeking', ->

          # destroy any existing _seekingMonitor
          beforeEach ->
            pv._seekingMonitor?.destroy()

          it 'should be a function', ->
            expect(typeof PlayerView::_monitorSeeking).toBe 'function'

          it 'should create a seeking monitor', ->
            expect(pv._seekingMonitor).not.toBeDefined()
            pv._monitorSeeking()
            expect(pv._seekingMonitor).toBeDefined()

          it 'should create a seeking monitor with the new offset', ->
            expect(pv._seekingMonitor).not.toBeDefined()
            pv._monitorSeeking 15
            expect(pv._seekingMonitor).toBeDefined()
            expect(pv._seekingMonitor.newOffset).toBe 15

          it 'should create a seeking monitor with a destroy method', ->
            expect(pv._seekingMonitor).not.toBeDefined()
            pv._monitorSeeking 15
            expect(pv._seekingMonitor).toBeDefined()
            expect(typeof pv._seekingMonitor.destroy).toBe 'function'

          it 'should create a seeking monitor with a destroy method that
              will destroy it', ->
            expect(pv._seekingMonitor).not.toBeDefined()
            pv._monitorSeeking 15
            expect(pv._seekingMonitor).toBeDefined()
            pv._seekingMonitor.destroy()
            expect(pv._seekingMonitor).not.toBeDefined()

          it 'should create a seeking monitor that self-destructs when the seek
              has completed', ->
            spyOn(pv, '_seekOffset').andReturn 0
            jasmine.Clock.useMock()
            expect(pv._seekingMonitor).not.toBeDefined()

            pv._monitorSeeking 15
            expect(pv._seekingMonitor).toBeDefined()

            jasmine.Clock.tick 200
            expect(pv._seekingMonitor).toBeDefined()

            pv._seekOffset.andReturn 15.1
            jasmine.Clock.tick 200
            expect(pv._seekingMonitor).not.toBeDefined()

          it 'should create a seeking monitor that self-destructs after 5
              seconds', ->
            spyOn(pv, 'seekOffset').andReturn 0
            jasmine.Clock.useMock()
            expect(pv._seekingMonitor).not.toBeDefined()

            pv._monitorSeeking 15
            expect(pv._seekingMonitor).toBeDefined()

            jasmine.Clock.tick 4999
            expect(pv._seekingMonitor).toBeDefined()

            jasmine.Clock.tick 2
            expect(pv._seekingMonitor).not.toBeDefined()

          it 'should create a seeking monitor that is destroyed by
              playerView.destroy', ->
            expect(pv._seekingMonitor).not.toBeDefined()
            pv._monitorSeeking 15
            expect(pv._seekingMonitor).toBeDefined()

            spy = spyOn(pv._seekingMonitor, 'destroy').andCallThrough()

            expect(spy).not.toHaveBeenCalled()
            pv.destroy()
            expect(spy).toHaveBeenCalled()


      it 'should look good', ->
        # setup DOM
        acorn.util.appendCss()
        $player = $('<div>').addClass('acorn-player').width(600).height(400)
            .appendTo('body')

        pv = new PlayerView viewOptions()

        # load player and cue video
        runs ->
          $player.append pv.render().el
          pv.$el.find('iframe').width(600).height(371)
        waitsFor (-> pv.player?.getPlayerState?()?), 'cued video', 10000


    describe 'YouTubeShell.RemixView', ->

      describe 'RemixView::defaultAttributes', ->

        it 'should default title to fetched youtube video title or url', ->
          rv = new RemixView viewOptions()

          rv._fetchedTitle = undefined
          rv._updateAttributesWithDefaults()
          expect(rv.model.title()).toBe videoLink

          rv._fetchedTitle = 'FakeYouTubeTitle'
          rv._updateAttributesWithDefaults()
          expect(rv.model.title()).toBe 'FakeYouTubeTitle'

        it 'should default thumbnail to youtube thumbnail link given id', ->
          rv = new RemixView viewOptions()
          ytThumbnailLink = "https://img.youtube.com/vi/#{youtubeId}/0.jpg"
          expect(rv.model.thumbnail()).toBe ytThumbnailLink


      describe 'RemixView::_defaultDescription', ->

        it 'should be a function', ->
          expect(typeof RemixView::_defaultDescription).toBe 'function'

        it 'should return a message about video title and clipping', ->
          rv = new RemixView viewOptions()

          rv._fetchedTitle = undefined
          expect(rv._defaultDescription()).toBe "YouTube video " +
              "\"#{videoLink}\" from 00:33 to 02:25."

          rv._fetchedTitle = 'FakeYouTubeTitle'
          expect(rv._defaultDescription()).toBe "YouTube video \"FakeYouTube" +
              "Title\" from 00:33 to 02:25."


      describe 'metaData', ->

        it 'should fetch properly', ->
          view = new RemixView viewOptions()
          metaData = view.metaData()

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs ->
            expect(metaData.synced()).toBe true
            expect(_.isObject metaData.data().data).toBe true

        it 'should update timeTotal', ->
          view = new RemixView viewOptions()
          model = view.model
          metaData = view.metaData()

          expect(model.timeTotal()).toBe 300

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs -> expect(model.timeTotal()).toBe metaData.data().data.duration

        it 'should update _fetchedTitle', ->
          view = new RemixView viewOptions()
          model = view.model
          metaData = view.metaData()

          expect(view._fetchedTitle).toBeUndefined()

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs -> expect(view._fetchedTitle).toBe metaData.data().data.title

        it 'should call `_updateAttributesWithDefaults`', ->
          view = new RemixView viewOptions()
          spyOn view, '_updateAttributesWithDefaults'
          expect(view._updateAttributesWithDefaults).not.toHaveBeenCalled()

          metaData = view.metaData()
          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs -> expect(view._updateAttributesWithDefaults).toHaveBeenCalled()
