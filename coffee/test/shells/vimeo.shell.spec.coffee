goog.provide 'acorn.specs.shells.VimeoShell'

goog.require 'acorn.shells.VimeoShell'
goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.VimeoShell', ->
  VimeoShell = acorn.shells.VimeoShell

  Model = VimeoShell.Model
  MediaView = VimeoShell.MediaView
  PlayerView = VimeoShell.PlayerView
  RemixView = VimeoShell.RemixView

  vimeoId = '8201078'
  modelOptions = -> link: "http://www.vimeo.com/#{vimeoId}"
  viewOptions = ->
    model: new Model modelOptions()
    eventhub: _.extend {}, Backbone.Events

  it 'should be part of acorn.shells', ->
    expect(VimeoShell).toBeDefined()

  acorn.util.test.describeShellModule VimeoShell, modelOptions(), ->

    validLinks = VimeoShell.validLinkPatterns
    expectLinkMatches = (link) ->
      expect(acorn.shells.LinkShell.linkMatches link, validLinks).toBe true


    describe 'VimeoShell', ->

      it 'should recognize player.vimeo.com/video/:id', ->
        expectLinkMatches "www.player.vimeo.com/video/#{vimeoId}"

      it 'should recognize player.vimeo.com/:id', ->
        expectLinkMatches "http://player.vimeo.com/#{vimeoId}"

      it 'should recognize vimeo.com/video/:id', ->
        expectLinkMatches "vimeo.com/video/#{vimeoId}"

      it 'should recognize vimeo.com/:id', ->
        expectLinkMatches "https://www.vimeo.com/#{vimeoId}"


    describe 'VimeoShell.Model', ->

      it 'should retrieve vimeo id from url', ->
        urls = [
          "www.player.vimeo.com/video/#{vimeoId}"
          "http://player.vimeo.com/#{vimeoId}"
          "vimeo.com/video/#{vimeoId}"
          "https://www.vimeo.com/#{vimeoId}"
        ]

        for url in urls
          model = new Model link: url
          expect(model.vimeoId()).toBe vimeoId

      it 'should have a valid metaDataUrl', ->
        model = new Model modelOptions()
        expect(model.metaDataUrl()).toBe "http://vimeo.com/api/v2/video/" +
            "#{vimeoId}.json?callback=?"

      it 'should fetch metadata', ->
        model = new Model modelOptions()
        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          cache = model.metaData()
          expect(cache.synced()).toBe true
          expect(athena.lib.util.isStrictObject cache.data()[0]).toBe true

      it 'should have a title method that uses metaData or link as title', ->
        model = new Model modelOptions()

        expect(model.title()).toBe modelOptions().link

        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          title = model.metaData().data()[0].title
          expect(model.title()).toBe title

      it 'should have a description method that describes the shell', ->
        _modelOptions = _.extend modelOptions(),
          timeStart: 33
          timeEnd: 145

        model = new Model _modelOptions

        expect(model.description()).toBe "Vimeo video #{_modelOptions.link}" +
            " from 00:33 to 02:25."

        retrieved = false

        runs ->
          model.metaData().sync success: => retrieved = true

        waitsFor (-> retrieved), 'retrieving metaData', 10000

        runs ->
          title = model.metaData().data()[0].title
          expect(model.description()).toBe "Vimeo video #{title} from 00:33" +
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
          timeTotal = model.metaData().data()[0].duration
          expect(model.timeTotal()).toBe timeTotal


    describe 'VimeoShell.PlayerView', ->
      it '------ TODO ------ make PlayerView tests work with PhantomJS', ->

    # TODO: most of these tests rely on in-DOM interaction with the vimeo API
    # of a nature that phantomJS does not support. Although all of the following
    # tests pass when run with `grunt server`, they fail when run with
    # `grunt test`
    xdescribe 'VimeoShell.PlayerView', ->

      it 'should load and ready a vimeo player on render', ->
        pv = new PlayerView viewOptions()
        setPlayerListener = false
        playerReady = false
        pvReady = false
        pv.on 'PlayerView:Ready', -> pvReady = true

        # setup DOM
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')

        # must be appended to DOM in order to load properly
        runs -> $hiddenPlayer.append pv.render().el

        waitsFor (->
          # if 'PlayerView:Ready' event fired before listener was set, settle
          # for inability to test low-level readiness and return true
          if pvReady and not setPlayerListener
            return true

          # if possible, add listener to froogaloop 'ready' event
          if pv.player? and not setPlayerListener
            setPlayerListener = true
            pv.player.addEvent 'ready', ->
              playerReady = true

              # call through (froogaloop overwrites old listener to ready)
              pv.onVimeoPlayerReady()

          # ideally, directly test both froogaloop 'ready' and playerView
          # 'PlayerView:Ready' events
          playerReady and pvReady
        ), 'player ready', 10000

      it 'should load a vimeo player on render that loads video when played', ->
        pv = new PlayerView viewOptions()

        loading = false
        # set 'loadProgress' listener and start playing on pv ready
        pv.on 'PlayerView:Ready', ->
          pv.player.addEvent 'loadProgress', (params) ->
            if parseFloat(params.percent) > 0
              loading = true

          pv.player.api 'play'

        # setup DOM
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')

        # must be appended to DOM in order to load properly
        runs -> $hiddenPlayer.append pv.render().el

        # wait for loading
        waitsFor (-> loading), 'video loading', 10000

      it 'should announce state changes', ->
        pv = new PlayerView viewOptions()

        # start playing on pv ready
        pv.on 'PlayerView:Ready', -> pv.player.api 'play'

        stateChanged = false
        pv.on 'PlayerView:StateChange', -> stateChanged = true

        # load player view
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')
        runs -> $hiddenPlayer.append pv.render().el

        waitsFor (-> stateChanged), 'state change event', 10000


      describe 'video player view api', ->
        pv = undefined
        $hiddenPlayer = undefined

        # froogaloop 'paused' query does not work, so track paused status
        # manually. for details on bug, see:
        #   https://github.com/vimeo/player-api/issues/31
        #   http://stackoverflow.com/questions/14119494/
        paused = true

        beforeEach ->
          pv = new PlayerView viewOptions()

          # set listeners and start playing on pv ready
          pv.on 'PlayerView:Ready', ->
            pv.player.addEvent 'play', -> paused = false
            pv.player.addEvent 'pause', -> paused = true

            pv.player.api 'play'

          # setup DOM
          acorn.util.appendCss()
          $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
              .height(400).appendTo('body')

          # must be appended to DOM in order to load properly
          runs -> $hiddenPlayer.append pv.render().el

          # wait for playing
          waitsFor (-> not paused), 'video to play', 10000

        afterEach ->
          pv.destroy()
          $hiddenPlayer.remove()
          paused = true

        it 'should play', ->
          # pause video with vimeo API, don't expect PLAYING state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          # play video, expect PLAYING state
          runs -> pv.play()
          waitsFor (-> not paused), 'video to play after pausing', 10000

        it 'should pause', ->
          expect(not paused).toBe true

          # pause video, expect PAUSED state
          runs -> pv.pause()
          waitsFor (-> paused), 'video to pause after playing', 10000

        it 'should seek, both when playing and when paused', ->
          seekOffset = undefined
          pv.player.addEvent 'seek', (params) ->
            seekOffset = parseInt params.seconds

          runs -> pv.seek 30
          waitsFor (->
            seekOffset == 30
          ), 'video to seek to 30 while playing', 10000

          runs -> pv.seek 40
          waitsFor (->
            seekOffset == 40
          ), 'video to seek to 40 while playing', 10000

          runs -> pv.seek 10
          waitsFor (->
            seekOffset == 10
          ), 'video to seek to 10 while playing', 10000

          runs -> pv.seek 20
          waitsFor (->
            seekOffset == 20
          ), 'video to seek to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          runs -> pv.seek 30
          waitsFor (->
            seekOffset == 30
          ), 'video to seek to 30 while paused', 10000

          runs -> pv.seek 40
          waitsFor (->
            seekOffset == 40
          ), 'video to seek to 40 while paused', 10000

          runs -> pv.seek 10
          waitsFor (->
            seekOffset == 10
          ), 'video to seek to 10 while paused', 10000

          runs -> pv.seek 20
          waitsFor (->
            seekOffset == 20
          ), 'video to seek to 20 while paused', 10000

        it 'should report whether or not it is playing', ->
          # remove listener to PlayerView:Ready and set up native vimeo shell
          # froogaloop event listeners again. this is necessary because the
          # addEvent function overwrites the old listener to an event - the
          # beforeEach block clobbered the shell's listener to the pause event
          pv.off 'PlayerView:Ready'
          pv.onVimeoPlayerReady()

          # expect PLAYING state
          runs -> expect(pv.isPlaying()).toBe true

          # pause video, expect PAUSED state
          runs -> pv.player.api 'pause'
          waitsFor (->
            not pv.isPlaying()
          ), 'playerView to register paused state', 10000

        it 'should report seek offset', ->
          runs -> pv.player.api 'seekTo', 30
          waitsFor (->
            pv.seekOffset() == 30
          ), 'playerView to register seekOffset to 30 while playing', 10000

          runs -> pv.player.api 'seekTo', 40
          waitsFor (->
            pv.seekOffset() == 40
          ), 'playerView to register seekOffset to 40 while playing', 10000

          runs -> pv.player.api 'seekTo', 10
          waitsFor (->
            pv.seekOffset() == 10
          ), 'playerView to register seekOffset to 10 while playing', 10000

          runs -> pv.player.api 'seekTo', 20
          waitsFor (->
            pv.seekOffset() == 20
          ), 'playerView to register seekOffset to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          runs -> pv.player.api 'seekTo', 30
          waitsFor (->
            pv.seekOffset() == 30
          ), 'playerView to register seekOffset to 30 while paused', 10000

          runs -> pv.player.api 'seekTo', 40
          waitsFor (->
            pv.seekOffset() == 40
          ), 'playerView to register seekOffset to 40 while paused', 10000

          runs -> pv.player.api 'seekTo', 10
          waitsFor (->
            pv.seekOffset() == 10
          ), 'playerView to register seekOffset to 10 while paused', 10000

          runs -> pv.player.api 'seekTo', 20
          waitsFor (->
            pv.seekOffset() == 20
          ), 'playerView to register seekOffset to 20 while paused', 10000


      it 'should look good', ->
        # setup DOM
        acorn.util.appendCss()
        $player = $('<div>').addClass('acorn-player').width(600).height(400)
            .appendTo('body')

        pv = new PlayerView viewOptions()
        pvReady = false
        pv.on 'PlayerView:Ready', -> pvReady = true

        # load player view
        runs ->
          $player.append pv.render().el
          pv.$el.find('iframe').width(600).height(371)
        waitsFor (-> pvReady), 'player view ready', 10000
