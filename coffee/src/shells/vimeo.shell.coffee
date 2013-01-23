goog.provide 'acorn.shells.VimeoShell'

goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'



VideoLinkShell = acorn.shells.VideoLinkShell
VimeoShell = acorn.shells.VimeoShell =

  id: 'acorn.VimeoShell'
  title: 'Vimeo Link'
  description: 'A shell for Vimeo videos.'
  icon: 'icon-play'
  validLinkPatterns: [
    acorn.util.urlRegEx('(www\.)?(player\.)?vimeo\.com\/(video\/)?([0-9]+).*')
  ]


class VimeoShell.Model extends VideoLinkShell.Model


  metaDataUrl: =>
    "http://vimeo.com/api/v2/video/#{@vimeoId()}.json?callback=?"


  description: =>
    start = acorn.util.Time.secondsToTimestring @timeStart()
    end = acorn.util.Time.secondsToTimestring @timeEnd()
    "Vimeo video #{@title() or @link()} from #{start} to #{end}."


  # returns the vimeo video id of this link.
  vimeoId: =>
    link = @link()

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect vimeo link, no video id found.'

    pattern.exec(link)[5]


  embedLink: =>
    # see http://developer.vimeo.com/player/embedding
    "http://player.vimeo.com/video/#{@vimeoId()}?" +
      '&byline=0' +
      '&portrait=0' +
      '&api=1' +
      '&player_id=vimeo-player' +
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


  metaData: =>
    if @model.metaDataUrl() and not @_metaData
      @_metaData = new athena.lib.util.RemoteResource
        url: @model.metaDataUrl()
        dataType: 'json'

    @_metaData



class VimeoShell.PlayerView extends VideoLinkShell.PlayerView


  className: @classNameExtend 'vimeo-shell'


  initialize: =>
    super
    @_timeTotal = undefined
    @_seekOffset = 0

    @on 'Media:Play', => @player.api 'play'
    @on 'Media:Pause', => @player.api 'pause'


  render: =>
    super
    @$el.empty()
    @$el.append acorn.util.iframe @model.embedLink(), 'vimeo-player'
    @initializeVimeo()
    @


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
    @player.api 'seekTo', 2
    @player.api 'seekTo', seconds


  seekOffset: =>
    @_seekOffset


  # Vimeo API - communication between the Vimeo js API and the shell.
  # see http://developer.vimeo.com/player/js-api
  vimeoPlayerApiSrc: 'http://a.vimeocdn.com/js/froogaloop2.min.js'


  # initialize vimeo API. should happen only once per page load
  initializeVimeo: =>

    # if Vimeo hasn't been initialized, initialize it.
    unless window.Froogaloop
      $.getScript @vimeoPlayerApiSrc, @onVimeoReady
      return

    # must call onVimeoReady once the current render call stack finishes
    # Vimeo API expects the id of a player currently on the page. Backbone may
    # have not yet added the current DOM subtree to the page DOM.
    setTimeout @onVimeoReady, 0


  onVimeoReady: =>
    # initialize the player object with the iframe
    @player = Froogaloop @$('#vimeo-player')[0]
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

    @trigger 'Media:DidReady'


  # Vimeo's api claims to hold playing-state constant through seeks, but seems
  # to play after any seek (and if previously paused, doesn't realize that the
  # state has changed).
  enforceVimeoPlaybackState: =>
    # get desirable state
    wasPlaying = @isInStatePlay()

    # force state to `PLAYING`
    @player.api 'play'

    # pause if appropriate
    unless wasPlaying
      @player.api 'pause'



# Register the shell with the acorn object.
acorn.registerShellModule VimeoShell
