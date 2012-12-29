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
  modelOptions = -> link: "http://www.youtube.com/watch?v=#{youtubeId}"
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
        expect(model.metaDataUrl()).toBe "http://gdata.youtube.com/feeds/" +
            "api/videos/#{youtubeId}?v=2&alt=jsonc"

      it 'should fetch metadata', ->
        model = new Model modelOptions()
        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          cache = model.metaData()
          expect(cache.synced()).toBe true
          expect(athena.lib.util.isStrictObject cache.data().data).toBe true

      it 'should have a title method that uses metaData or link as title', ->
        model = new Model modelOptions()

        expect(model.title()).toBe modelOptions().link

        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          title = model.metaData().data().data.title
          expect(model.title()).toBe title

      it 'should have a description method that describes the shell', ->
        _modelOptions = _.extend modelOptions(),
          timeStart: 33
          timeEnd: 145

        model = new Model _modelOptions

        expect(model.description()).toBe "YouTube video #{_modelOptions.link}" +
            " from 00:33 to 02:25."

        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          title = model.metaData().data().data.title
          expect(model.description()).toBe "YouTube video #{title} from 00:33" +
              " to 02:25."

      it 'should have a timeTotal method that returns metaData.duration or
          Infinity', ->
        model = new Model modelOptions()

        expect(model.timeTotal()).toBe Infinity

        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          timeTotal = model.metaData().data().data.duration
          expect(model.timeTotal()).toBe timeTotal


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
        waitsFor (-> pv.player?.getPlayerState?() >= 0), 'cued video', 10000

      it 'should announce state changes', ->
        pv = new PlayerView viewOptions()

        eventFired = false
        pv.on 'PlayerView:StateChange', -> eventFired = true

        # load player and cue video
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')
        runs -> $hiddenPlayer.append pv.render().el
        waitsFor (-> pv.player?.getPlayerState?() >= 0), 'cued video', 10000

        runs -> pv.player.playVideo()

        waitsFor (-> eventFired), 'state change event', 10000

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
          waitsFor (-> pv.player?.getPlayerState?() >= 0), 'cued video', 10000

          # play video, wait for playing state
          runs -> pv.player.playVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PLAYING
          ), 'video to play', 10000

        afterEach ->
          pv.destroy()
          $hiddenPlayer.remove()

        it 'should play', ->
          # pause video with youtube API, don't expect PLAYING state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() != YT.PlayerState.PLAYING
          ), 'video to pause with API', 10000

          # play video, expect PLAYING state
          runs -> pv.play()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PLAYING
          ), 'video to play after pausing', 10000

        it 'should pause', ->
          # pause video, expect PAUSED state
          runs -> pv.pause()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause after playing', 10000

        it 'should seek, both when playing and when paused', ->
          runs -> pv.seek 30
          waitsFor (->
            pv.player.getCurrentTime() == 30
          ), 'video to seek to 30 while playing', 10000

          runs -> pv.seek 40
          waitsFor (->
            pv.player.getCurrentTime() == 40
          ), 'video to seek to 40 while playing', 10000

          runs -> pv.seek 10
          waitsFor (->
            pv.player.getCurrentTime() == 10
          ), 'video to seek to 10 while playing', 10000

          runs -> pv.seek 20
          waitsFor (->
            pv.player.getCurrentTime() == 20
          ), 'video to seek to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause with API', 10000

          runs -> pv.seek 30
          waitsFor (->
            pv.player.getCurrentTime() == 30
          ), 'video to seek to 30 while paused', 10000

          runs -> pv.seek 40
          waitsFor (->
            pv.player.getCurrentTime() == 40
          ), 'video to seek to 40 while paused', 10000

          runs -> pv.seek 10
          waitsFor (->
            pv.player.getCurrentTime() == 10
          ), 'video to seek to 10 while paused', 10000

          runs -> pv.seek 20
          waitsFor (->
            pv.player.getCurrentTime() == 20
          ), 'video to seek to 20 while paused', 10000

        it 'should report whether or not it is playing', ->
          # expect PLAYING state
          runs -> expect(pv.isPlaying()).toBe true

          # pause video, expect PAUSED state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            not pv.isPlaying()
          ), 'playerView to register paused state', 10000

        it 'should report seek offset', ->
          runs -> pv.player.seekTo 30
          waitsFor (->
            pv.seekOffset() == 30
          ), 'playerView to register seekOffset to 30 while playing', 10000

          runs -> pv.player.seekTo 40
          waitsFor (->
            pv.seekOffset() == 40
          ), 'playerView to register seekOffset to 40 while playing', 10000

          runs -> pv.player.seekTo 10
          waitsFor (->
            pv.seekOffset() == 10
          ), 'playerView to register seekOffset to 10 while playing', 10000

          runs -> pv.player.seekTo 20
          waitsFor (->
            pv.seekOffset() == 20
          ), 'playerView to register seekOffset to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.pauseVideo()
          waitsFor (->
            pv.player.getPlayerState() == YT.PlayerState.PAUSED
          ), 'video to pause with API', 10000

          runs -> pv.player.seekTo 30
          waitsFor (->
            pv.seekOffset() == 30
          ), 'playerView to register seekOffset to 30 while paused', 10000

          runs -> pv.player.seekTo 40
          waitsFor (->
            pv.seekOffset() == 40
          ), 'playerView to register seekOffset to 40 while paused', 10000

          runs -> pv.player.seekTo 10
          waitsFor (->
            pv.seekOffset() == 10
          ), 'playerView to register seekOffset to 10 while paused', 10000

          runs -> pv.player.seekTo 20
          waitsFor (->
            pv.seekOffset() == 20
          ), 'playerView to register seekOffset to 20 while paused', 10000

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
        waitsFor (-> pv.player?.getPlayerState?() >= 0), 'cued video', 10000
