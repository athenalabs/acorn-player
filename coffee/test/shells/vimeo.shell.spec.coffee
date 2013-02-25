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
  videoLink = "http://www.vimeo.com/#{vimeoId}"

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
        expect(model.metaDataUrl()).toBe "https://vimeo.com/api/v2/video/" +
            "#{vimeoId}.json?callback=?"


    describe 'VimeoShell.PlayerView', ->
      it '------ TODO ------ make PlayerView tests work with PhantomJS', ->

    # TODO: most of these tests rely on in-DOM interaction with the vimeo API
    # of a nature that phantomJS does not support. Although all of the following
    # tests pass when run with `grunt server`, they fail when run with
    # `grunt test`
    xdescribe 'VimeoShell.PlayerView', ->
      pv = undefined
      $hiddenPlayer = undefined

      beforeEach ->
        pv = new PlayerView viewOptions()

        # setup DOM
        acorn.util.appendCss()
        $hiddenPlayer = $('<div>').addClass('acorn-player hidden').width(600)
            .height(400).appendTo('body')

      afterEach ->
        pv.destroy()
        $hiddenPlayer.remove()

      it 'should load and ready a vimeo player on render', ->
        setPlayerListener = false
        playerReady = false
        pvReady = false
        pv.on 'Media:DidReady', -> pvReady = true
        spyOn(pv, 'onVimeoPlayerReady').andCallThrough()

        # must be appended to DOM in order to load properly
        runs -> $hiddenPlayer.append pv.render().el

        waitsFor (->
          pv.onVimeoPlayerReady.callCount > 0
        ), 'player ready', 10000

      it 'should load a vimeo player on render that loads video when played', ->
        loading = false
        # set 'loadProgress' listener and start playing on pv ready
        pv.on 'Media:DidReady', ->
          pv.player.addEvent 'loadProgress', (params) ->
            if parseFloat(params.percent) > 0
              loading = true

          pv.player.api 'play'

        # must be appended to DOM in order to load properly
        runs -> $hiddenPlayer.append pv.render().el

        # wait for loading
        waitsFor (-> loading), 'video loading', 10000

      it 'should announce state changes', ->
        # start playing on pv ready
        pv.on 'Media:DidReady', -> pv.player.api 'play'

        stateChanged = false
        pv.on 'Media:DidPlay', -> stateChanged = true
        runs -> $hiddenPlayer.append pv.render().el

        waitsFor (-> stateChanged), 'state change event', 10000


      describe 'video player view api', ->
        paused = undefined

        beforeEach ->
          # froogaloop 'paused' query does not work, so track paused status
          # manually. for details on bug, see:
          #   https://github.com/vimeo/player-api/issues/31
          #   http://stackoverflow.com/questions/14119494/
          paused = true

          # set listeners and start playing on pv ready
          pv.on 'Media:DidReady', ->
            pv.player.addEvent 'play', -> paused = false
            pv.player.addEvent 'pause', -> paused = true

            pv.player.api 'play'

          # must be appended to DOM in order to load properly
          runs -> $hiddenPlayer.append pv.render().el

          # wait for playing
          waitsFor (-> not paused), 'video to play', 10000

        it 'should play (vimeo api)', ->
          # pause video with vimeo API, don't expect PLAYING state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          # play video, expect PLAYING state
          runs -> pv.player.api 'play'
          waitsFor (-> not paused), 'video to play after pausing', 10000

        it 'should play (media api)', ->
          # pause video with vimeo API, don't expect PLAYING state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          # play video, expect PLAYING state
          runs -> pv.play()
          waitsFor (-> not paused), 'video to play after pausing', 10000

        it 'should pause (vimeo api)', ->
          expect(not paused).toBe true

          # pause video, expect PAUSED state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause after playing', 10000

        it 'should pause (media api)', ->
          runs -> pv.play()
          waitsFor (-> not paused), 'video should not be paused', 10000

          # pause video, expect PAUSED state
          runs -> pv.pause()
          waitsFor (-> paused), 'video to pause after playing', 10000

        it 'should seek, both when playing and when paused', ->
          seekOffset = undefined
          pv.player.addEvent 'seek', (params) ->
            seekOffset = parseInt params.seconds

          runs -> pv._seek 30
          waitsFor (->
            seekOffset == 30
          ), 'video to seek to 30 while playing', 10000

          runs -> pv._seek 40
          waitsFor (->
            seekOffset == 40
          ), 'video to seek to 40 while playing', 10000

          runs -> pv._seek 10
          waitsFor (->
            seekOffset == 10
          ), 'video to seek to 10 while playing', 10000

          runs -> pv._seek 20
          waitsFor (->
            seekOffset == 20
          ), 'video to seek to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          runs -> pv._seek 30
          waitsFor (->
            seekOffset == 30
          ), 'video to seek to 30 while paused', 10000

          runs -> pv._seek 40
          waitsFor (->
            seekOffset == 40
          ), 'video to seek to 40 while paused', 10000

          runs -> pv._seek 10
          waitsFor (->
            seekOffset == 10
          ), 'video to seek to 10 while paused', 10000

          runs -> pv._seek 20
          waitsFor (->
            seekOffset == 20
          ), 'video to seek to 20 while paused', 10000

        it 'should report whether or not it is playing', ->
          # remove listener to Media:DidReady and set up native vimeo shell
          # froogaloop event listeners again. this is necessary because the
          # addEvent function overwrites the old listener to an event - the
          # beforeEach block clobbered the shell's listener to the pause event
          pv.off 'Media:DidReady'
          pv.onVimeoPlayerReady()

          # pause video, expect PAUSED state
          runs -> pv.player.api 'pause'
          waitsFor (->
            not pv.isPlaying()
          ), 'playerView to register paused state', 10000

          # play video, expect PLAYING state
          runs -> pv.player.api 'play'
          waitsFor (->
            pv.isPlaying()
          ), 'playerView to register playing state', 10000

        it 'should report seek offset', ->
          runs -> pv.player.api 'seekTo', 30
          waitsFor (->
            pv._seekOffset() == 30
          ), 'playerView to register seekOffset to 30 while playing', 10000

          runs -> pv.player.api 'seekTo', 40
          waitsFor (->
            pv._seekOffset() == 40
          ), 'playerView to register seekOffset to 40 while playing', 10000

          runs -> pv.player.api 'seekTo', 10
          waitsFor (->
            pv._seekOffset() == 10
          ), 'playerView to register seekOffset to 10 while playing', 10000

          runs -> pv.player.api 'seekTo', 20
          waitsFor (->
            pv._seekOffset() == 20
          ), 'playerView to register seekOffset to 20 while playing', 10000

          # achieve paused state
          runs -> pv.player.api 'pause'
          waitsFor (-> paused), 'video to pause with API', 10000

          runs -> pv.player.api 'seekTo', 30
          waitsFor (->
            pv._seekOffset() == 30
          ), 'playerView to register seekOffset to 30 while paused', 10000

          runs -> pv.player.api 'seekTo', 40
          waitsFor (->
            pv._seekOffset() == 40
          ), 'playerView to register seekOffset to 40 while paused', 10000

          runs -> pv.player.api 'seekTo', 10
          waitsFor (->
            pv._seekOffset() == 10
          ), 'playerView to register seekOffset to 10 while paused', 10000

          runs -> pv.player.api 'seekTo', 20
          waitsFor (->
            pv._seekOffset() == 20
          ), 'playerView to register seekOffset to 20 while paused', 10000


      it 'should look good', ->
        $player = $hiddenPlayer.removeClass 'hidden'

        pvReady = false
        pv.on 'Media:DidReady', -> pvReady = true

        # load player view
        runs ->
          $player.append pv.render().el
          pv.$el.find('iframe').width(600).height(371)
        waitsFor (-> pvReady), 'player view ready', 10000

        runs ->
          # stub afterEach pv.destroy() and $hiddenPlayer.remove() calls so that
          # playerView remains in DOM
          pv = destroy: ->
          $hiddenPlayer = remove: ->


    describe 'VimeoShell.RemixView', ->

      describe 'RemixView::defaultAttributes', ->

        it 'should default title to fetched vimeo video title or url', ->
          rv = new RemixView viewOptions()

          rv._fetchedTitle = undefined
          rv._updateAttributesWithDefaults()
          expect(rv.model.title()).toBe videoLink

          rv._fetchedTitle = 'FakeVimeoTitle'
          rv._updateAttributesWithDefaults()
          expect(rv.model.title()).toBe 'FakeVimeoTitle'

        it 'should default thumbnail to fetched vimeo video thumbnail if it
            exists', ->
          rv = new RemixView viewOptions()

          rv._fetchedThumbnail = 'thumbnails.com/fake.jpg'
          rv._updateAttributesWithDefaults()
          expect(rv.model.thumbnail()).toBe 'thumbnails.com/fake.jpg'


      describe 'RemixView::_defaultDescription', ->

        it 'should be a function', ->
          expect(typeof RemixView::_defaultDescription).toBe 'function'

        it 'should return a message about video title and clipping', ->
          rv = new RemixView viewOptions()

          rv._fetchedTitle = undefined
          expect(rv._defaultDescription()).toBe "Vimeo video \"#{videoLink}\"" +
              " from 00:33 to 02:25."

          rv._fetchedTitle = 'FakeVimeoTitle'
          expect(rv._defaultDescription()).toBe "Vimeo video \"FakeVimeoTitle" +
              "\" from 00:33 to 02:25."


      describe 'metaData', ->

        it 'should fetch properly', ->
          view = new RemixView viewOptions()
          metaData = view.metaData()

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs ->
            expect(metaData.synced()).toBe true
            expect(athena.lib.util.isStrictObject metaData.data()[0]).toBe true

        it 'should update timeTotal', ->
          view = new RemixView viewOptions()
          model = view.model
          metaData = view.metaData()

          expect(model.timeTotal()).toBe 300

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs -> expect(model.timeTotal()).toBe metaData.data()[0].duration

        it 'should update _fetchedTitle', ->
          view = new RemixView viewOptions()
          model = view.model
          metaData = view.metaData()

          expect(view._fetchedTitle).toBeUndefined()

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs -> expect(model.title()).toBe metaData.data()[0].title

        it 'should update _fetchedThumbnail', ->
          view = new RemixView viewOptions()
          model = view.model
          metaData = view.metaData()

          expect(view._fetchedThumbnail).toBeUndefined()

          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs ->
            thumbnail = metaData.data()[0].thumbnail_large
            expect(view._fetchedThumbnail).toBe thumbnail

        it 'should call `_updateAttributesWithDefaults`', ->
          view = new RemixView viewOptions()
          spyOn view, '_updateAttributesWithDefaults'
          expect(view._updateAttributesWithDefaults).not.toHaveBeenCalled()

          metaData = view.metaData()
          waitsFor (-> metaData.synced()), 'retrieving metaData', 10000
          runs -> expect(view._updateAttributesWithDefaults).toHaveBeenCalled()
