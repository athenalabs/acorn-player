goog.provide 'acorn.shells.YouTubeShell'

goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'



VideoLinkShell = acorn.shells.VideoLinkShell
YouTubeShell = acorn.shells.YouTubeShell =

  id: 'acorn.YouTubeShell'
  title: 'YouTube'
  description: 'a YouTube video'
  icon: 'icon-play'
  validLinkPatterns: [
    acorn.util.urlRegEx('(www\.)?youtube\.com\/v\/([A-Za-z0-9\-_]+).*')
    acorn.util.urlRegEx('(www\.)?youtube\.com\/embed\/([A-Za-z0-9\-_]+).*')
    acorn.util.urlRegEx('(www\.)?youtube\.com\/watch\?.*v=([A-Za-z0-9\-_]+).*')
    acorn.util.urlRegEx('(www\.)?y2u.be\/([A-Za-z0-9\-_]+)')
    acorn.util.urlRegEx('(www\.)?youtu\.be\/([A-Za-z0-9\-_]+).*')
    acorn.util.urlRegEx('(www\.)?youtube\.googleapis\.com\/v\/([A-Za-z0-9\-_]+).*')
  ]



class YouTubeShell.Model extends VideoLinkShell.Model


  metaDataUrl: =>
    "https://gdata.youtube.com/feeds/api/videos/#{@youtubeId()}?v=2&alt=jsonc"


  # returns the youtube video id of this link.
  youtubeId: =>
    link = @get('link')

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect youtube link, no video id found.'

    pattern.exec(link)[3]


  embedLink: (options) =>
    # see https://developers.google.com/youtube/player_parameters for options
    "https://www.youtube.com/embed/#{@youtubeId()}?" +
         '&fs=1' +
       # '&modestbranding=1' +
         '&iv_load_policy=3' +
         '&rel=0' +
         '&showsearch=0' +
         '&showinfo=0' +
         '&hd=1' +
         '&wmode=transparent' +
         '&enablejsapi=1' +
         "&controls=#{if options.noControls then 0 else 1}"

    # Thumbnail Link can be accessed via:
    # "https://img.youtube.com/vi/#{@youtubeId()}/0.jpg"
    # Use this to set the thumbnail initially in the RemixView. Thumbnail
    # is afterwards entirely changeable by the user (i.e. stored in data).



class YouTubeShell.MediaView extends VideoLinkShell.MediaView


  className: @classNameExtend 'youtube-shell'


class YouTubeShell.RemixView extends VideoLinkShell.RemixView


  className: @classNameExtend 'youtube-shell'


  initialize: =>
    super
    @metaData().sync success: @onMetaDataSync


  defaultAttributes: =>
    superDefaults = super

    _.extend superDefaults,
      title: @_fetchedTitle or superDefaults.title
      thumbnail: "https://img.youtube.com/vi/#{@model.youtubeId()}/0.jpg"


  _defaultDescription: =>
    start = acorn.util.Time.secondsToTimestring @model.timeStart()
    end = acorn.util.Time.secondsToTimestring @model.timeEnd()
    "YouTube video \"#{@_fetchedTitle ? @model.link()}\" from #{start} to " +
        "#{end}."


  onMetaDataSync: (data) =>
    @_fetchedTitle = data.data.title
    @model.timeTotal data.data.duration

    @_updateAttributesWithDefaults()
    @_setTimeInputMax()


  metaData: =>
    if @model.metaDataUrl() and not @_metaData
      @_metaData = new athena.lib.util.RemoteResource
        url: @model.metaDataUrl()
        dataType: 'json'

    @_metaData


class YouTubeShell.PlayerView extends VideoLinkShell.PlayerView


  className: @classNameExtend 'youtube-shell'


  events: => _.extend super,
    'click .click-capture': => @togglePlayPause()


  initialize: =>
    super
    @on 'Media:Play', => @player?.playVideo?()
    @on 'Media:Pause', => @player?.pauseVideo?()
    @on 'Media:End', => @player?.pauseVideo?()
    @initializeYouTubeAPI()


  render: =>
    super
    @$el.empty()
    options = noControls: @options.noControls
    @$el.append acorn.util.iframe @model.embedLink(options), @playerId()
    @$el.append $('<div>').addClass('click-capture')

    # initialize in next call stack, after render.
    # YouTube requires the element to be in the DOM
    setTimeout(@initializeYouTubePlayer, 0)
    @


  # id for the player element. id must be unique in the entire page to allow
  # the YouTube API to differentiate between multiple players.
  playerId: =>
    "youtube-player-#{@cid}"


  _seekOffset: =>
    @player?.getCurrentTime?() ? 0


  _seek: (seconds) =>
    # Unless playing, seek first to the wrong place. YouTube's player has a bug
    # such that, when not playing, it occasionally seeks incorrectly (this seems
    # to happen after 2 correct seeks)
    unless @isPlaying()
      wrongPlace = if seconds + 1 < @model.timeTotal()
        seconds + 18
      else
        if seconds - 1 >= 0 then 0 else seconds
      @player?.seekTo?(wrongPlace, true)

    @player?.seekTo?(seconds, true)


  duration: =>
    @model.duration() ? (@player?.getDuration?() or 0)


  _playbackIsAfterEnd: (current) =>
    if super
      true
    else
      @_playerInEndedState ? false


  isInState: (state) =>
    isInState = super
    unless window.YT and @player?.getPlayerState
      return isInState

    ytState = @player.getPlayerState()

    # ensure that YT State matches our expectations.
    switch state
      when 'play'
        ytIsInState = ytState == YT.PlayerState.PLAYING or
                      ytState == YT.PlayerState.BUFFERING
      when 'pause'
        ytIsInState = ytState == YT.PlayerState.PAUSED
      when 'end'
        ytIsInState = ytState == YT.PlayerState.ENDED
      else
        ytIsInState = undefined

    if ytIsInState isnt isInState
      console.log 'Error: YT player must agree with internal state'
      console.log "internal: #{@mediaState()} youtube: #{ytState}"

    isInState


  # YouTube API - communication between the YouTube iframe API and the shell.
  # see https://developers.google.com/youtube/iframe_api_reference
  youTubePlayerApiSrc: '//www.youtube.com/iframe_api'


  # initialize youtube API. should happen only once per page load
  initializeYouTubeAPI: =>

    # if YouTube hasn't been initialized, initialize it.
    unless window.YT or YouTubeShell._initializedYouTubeAPI
      YouTubeShell._initializedYouTubeAPI = true
      $.getScript @youTubePlayerApiSrc


  initializeYouTubePlayer: =>

    # wait until the YT.Player class is there
    unless window.YT and YT.Player
      @initializeYouTubeAPI()
      setTimeout @initializeYouTubePlayer, 100
      return

    # create the player object
    @player = new YT.Player @playerId(), events:

      onReady: =>
        # this *should* initialize the playback at the correct point but
        # doesn't. Need a more robust solution (tick)
        start = parseInt(@model.timeStart() ? 0, 10)
        @player.loadVideoById(@model.youtubeId(), start)
        @player.playVideo()
        @player.pauseVideo()

        # playing still needs buffering sometimes. hack: play then pause
        @setMediaState 'ready'


      onStateChange: (event) =>
        # track youtube ended state
        @_playerInEndedState = event.data == 0


# Register the shell with the acorn object.
acorn.registerShellModule(YouTubeShell)
