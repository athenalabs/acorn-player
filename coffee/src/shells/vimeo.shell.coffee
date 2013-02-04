goog.provide 'acorn.shells.VimeoShell'

goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'



VideoLinkShell = acorn.shells.VideoLinkShell
VimeoShell = acorn.shells.VimeoShell =

  id: 'acorn.VimeoShell'
  title: 'Vimeo'
  description: 'Vimeo videos.'
  icon: 'icon-play'
  validLinkPatterns: [
    acorn.util.urlRegEx('(www\.)?(player\.)?vimeo\.com\/(video\/)?([0-9]+).*')
  ]


class VimeoShell.Model extends VideoLinkShell.Model


  metaDataUrl: =>
    "https://vimeo.com/api/v2/video/#{@vimeoId()}.json?callback=?"


  defaultDescription: =>
    start = acorn.util.Time.secondsToTimestring @timeStart()
    end = acorn.util.Time.secondsToTimestring @timeEnd()
    "Vimeo video \"#{@title()}\" from #{start} to #{end}."


  # returns the vimeo video id of this link.
  vimeoId: =>
    link = @link()

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect vimeo link, no video id found.'

    pattern.exec(link)[5]


  # id for the player element. id must be unique in the entire page to allow
  # the YouTube API to differentiate between multiple players.
  playerId: =>
    "vimeo-player-#{@cid}"


  embedLink: =>
    # see http://developer.vimeo.com/player/embedding
    "https://player.vimeo.com/video/#{@vimeoId()}?" +
      '&byline=0' +
      '&portrait=0' +
      '&api=1' +
      '&player_id=' + @playerId() +
      '&title=0' +
      '&byline=1' +
      '&portrait=0' +
      '&color=ffffff'



class VimeoShell.MediaView extends VideoLinkShell.MediaView


  className: @classNameExtend 'vimeo-shell'



class VimeoShell.RemixView extends VideoLinkShell.RemixView


  className: @classNameExtend 'vimeo-shell'


  initialize: =>
    super
    @metaData().sync success: @onMetaDataSync


  onMetaDataSync: (data) =>
    @model.title data[0].title
    @model.timeTotal data[0].duration
    @model.defaultThumbnail data[0].thumbnail_large
    @_setTimeInputMax()


  metaData: =>
    if @model.metaDataUrl() and not @_metaData
      @_metaData = new athena.lib.util.RemoteResource
        url: @model.metaDataUrl()
        dataType: 'json'

    @_metaData



class VimeoShell.PlayerView extends VideoLinkShell.PlayerView


  className: @classNameExtend 'vimeo-shell'


  events: => _.extend super,
    'click .click-capture': => @togglePlayPause()


  initialize: =>
    super
    @_timeTotal = undefined
    @_seekOffset = 0

    @on 'Media:Play', => @player?.api?('play')
    @on 'Media:Pause', => @player?.api?('pause')
    @on 'Media:End', => @player?.api?('pause')

    @initializeVimeoAPI()


  render: =>
    super
    @$el.empty()
    @$el.append acorn.util.iframe @model.embedLink(), @playerId()
    @$el.append $('<div>').addClass('click-capture')

    # initialize in next call stack, after render.
    # Vimeo requires the element to be in the DOM
    setTimeout @initializeVimeoPlayer, 0
    @


  playerId: =>
    @model.playerId()


  # Control the player
  seek: (seconds) =>
    # Vimeo adds the original seekTo value to the current one. `seekTo n`
    # initially sends a user to t = n, but forever after will send the user to
    # t = 2n - 2. `seekTo 6` initially sends a user to t = 6, but will later
    # send to t = ~10. See https://github.com/vimeo/player-api/issues/30.
    #
    # Hack: seekTo 2, then seekTo desired value.
    #
    # Note: Vimeo also has a bug that mangles playback after a `seekTo 0` call.
    # See https://github.com/vimeo/player-api/issues/27. In the case that
    # `seconds == 0`, we may need to handle things specially. Haven't yet QA'd
    # for bugs on this point, just ran across it once.
    @player.api?('seekTo', 2)
    @player.api?('seekTo', seconds)


  seekOffset: =>
    @_seekOffset


  # Vimeo API - communication between the Vimeo js API and the shell.
  # see http://developer.vimeo.com/player/js-api
  vimeoPlayerApiSrc: 'https://secure-a.vimeocdn.com/js/froogaloop2.min.js'


  # initialize vimeo API. should happen only once per page load
  initializeVimeoAPI: =>
    unless window.Froogaloop or VimeoShell._initializedVimeoAPI
      VimeoShell._initializedVimeoAPI = true
      $.getScript @vimeoPlayerApiSrc


  initializeVimeoPlayer: =>
    unless window.Froogaloop
      @initializeVimeoAPI()
      setTimeout @initializeVimeoPlayer, 100
      return

    # initialize the player object with the iframe
    @player = Froogaloop @$('#' + @playerId())[0]
    @player.addEvent 'ready', @onVimeoPlayerReady


  onVimeoPlayerReady: =>
    # attach callbacks to the vimeo player.
    @player.addEvent 'pause', => @pause()

    @player.addEvent 'play', => @play()

    @player.addEvent 'seek', (params) =>
      @_seekOffset = parseFloat params.seconds
      @enforceVimeoPlaybackState()

    @player.addEvent 'playProgress', (params) =>
      @_timeTotal = parseFloat params.duration
      @_seekOffset = parseFloat params.seconds

    @player.api?('play')
    @player.api?('pause')
    @setMediaState 'ready'


  # Vimeo's api claims to hold playing-state constant through seeks, but seems
  # to play after any seek (and if previously paused, doesn't realize that the
  # state has changed).
  enforceVimeoPlaybackState: =>
    # get desirable state
    wasPlaying = @isPlaying()

    # force state to `PLAYING`
    @player.api?('play')

    # pause if appropriate
    unless wasPlaying
      @player.api?('pause')



# Register the shell with the acorn object.
acorn.registerShellModule VimeoShell
