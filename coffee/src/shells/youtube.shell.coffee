goog.provide 'acorn.shells.YouTubeShell'

goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'



VideoLinkShell = acorn.shells.VideoLinkShell
YouTubeShell = acorn.shells.YouTubeShell =

  id: 'acorn.YouTubeShell'
  title: 'YouTubeShell'
  description: 'A shell for YouTube videos.'
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
    "http://gdata.youtube.com/feeds/api/videos/#{@youtubeId()}?v=2&alt=jsonc"


  description: =>
    start = acorn.util.Time.secondsToTimestring @timeStart()
    end = acorn.util.Time.secondsToTimestring @timeEnd()
    "YouTube video #{@title()} from #{start} to #{end}."


  # returns the youtube video id of this link.
  youtubeId: =>
    link = @get('link')

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect youtube link, no video id found.'

    pattern.exec(link)[3]


  defaultThumbnail: =>
    "//img.youtube.com/vi/#{@youtubeId()}/0.jpg"


  embedLink: (options) =>
    # see https://developers.google.com/youtube/player_parameters for options
    "http://www.youtube.com/embed/#{@youtubeId()}?" +
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


  onMetaDataSync: (data) =>
    @model.title data.data.title
    @model.timeTotal data.data.duration


  metaData: =>
    if @model.metaDataUrl() and not @_metaData
      @_metaData = new athena.lib.util.RemoteResource
        url: @model.metaDataUrl()
        dataType: 'json'

    @_metaData


class YouTubeShell.PlayerView extends VideoLinkShell.PlayerView


  className: @classNameExtend 'youtube-shell'


  initialize: =>
    super
    @on 'Media:Play', => @player?.playVideo()
    @on 'Media:Pause', => @player?.pauseVideo()
    @initializeYouTubeAPI()


  render: =>
    super
    @$el.empty()
    options = noControls: @options.noControls
    @$el.append acorn.util.iframe @model.embedLink(options), @playerId()

    # initialize in next call stack, after render.
    # YouTube requires the element to be in the DOM
    setTimeout(@initializeYouTubePlayer, 0)
    @


  # id for the player element. id must be unique in the entire page to allow
  # the YouTube API to differentiate between multiple players.
  playerId: =>
    "youtube-player-#{@cid}"


  seekOffset: =>
    @player?.getCurrentTime?() ? 0


  seek: (seconds) =>
    # Unless playing, seek first to the wrong place. YouTube's player has a bug
    # such that, when not playing, it occasionally seeks incorrectly (this seems
    # to happen after 2 correct seeks)
    unless @isPlaying()
      wrongPlace = if seconds + 1 < @model.timeTotal()
        seconds + 18
      else
        if seconds - 1 >= 0 then 0 else seconds
      @player?.seekTo(wrongPlace, true)

    @player?.seekTo(seconds, true)


  isInState: (state) =>
    isInState = super
    ytState = @player?.getPlayerState?()

    # ensure that YT State matches our expectations.
    switch state
      when state is 'play'
        ytIsInState = ytState == YT.PlayerState.PLAYING
      when state is 'pause'
        ytIsInState = ytState == YT.PlayerState.PAUSED
      when state is 'end'
        ytIsInState = ytState == YT.PlayerState.ENDED
      else
        ytIsInState = undefined

    if ytIsInState isnt isInState
      console.log 'Error: YT player must agree with internal state'

    isInState


  # YouTube API - communication between the YouTube iframe API and the shell.
  # see https://developers.google.com/youtube/iframe_api_reference
  youTubePlayerApiSrc: 'http://www.youtube.com/iframe_api'


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
        @player.cueVideoById(@model.youtubeId(), start)
        @setMediaState 'ready'


      onStateChange: (event) =>
        switch @player.getPlayerState()
          when YT.PlayerState.PLAYING
            @setMediaState 'play'
          when YT.PlayerState.PAUSED
            @setMediaState 'pause'
          when YT.PlayerState.ENDED
            @setMediaState 'end'



# Register the shell with the acorn object.
acorn.registerShellModule(YouTubeShell)
