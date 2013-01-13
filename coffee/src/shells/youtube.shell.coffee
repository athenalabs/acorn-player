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


  timeTotal: =>
    currTotal = super
    cache = @metaData()

    if cache.synced()
      timeTotal = cache.data().data.duration
      @set('timeTotal', timeTotal) unless currTotal == timeTotal
      timeTotal
    else
      @get('timeTotal') ? Infinity


  title: =>
    cache = @metaData()
    if cache.synced() then cache.data().data.title else @get('link')


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



class YouTubeShell.PlayerView extends VideoLinkShell.PlayerView


  className: @classNameExtend 'youtube-shell'


  render: =>
    super
    @$el.empty()
    options = noControls: @options.noControls
    @$el.append acorn.util.iframe @model.embedLink(options), @playerId()
    @initializeYouTubeAPI()
    @


  # id for the player element. id must be unique in the entire page to allow
  # the YouTube API to differentiate between multiple players.
  playerId: =>
    "youtube-player-#{@cid}"


  # Control the player


  play: =>
    @player?.playVideo()


  pause: =>
    @player?.pauseVideo()


  seek: (seconds) =>
    # Unless playing, seek first to the wrong place. YouTube's player has a bug
    # such that, when not playing, it occasionally seeks incorrectly (this seems
    # to happen after 2 correct seeks)
    unless @isPlaying()
      wrongPlace = if seconds + 1 < @model.timeTotal()
        seconds + 1
      else
        if seconds - 1 >= 0 then 0 else seconds
      @player?.seekTo(wrongPlace, true)

    @player?.seekTo(seconds, true)


  isPlaying: =>
    @player?.getPlayerState() == YT.PlayerState.PLAYING


  seekOffset: =>
    @player?.getCurrentTime() ? 0



  # YouTube API - communication between the YouTube iframe API and the shell.
  # see https://developers.google.com/youtube/iframe_api_reference
  youTubePlayerApiSrc: 'http://www.youtube.com/iframe_api'


  # initialize youtube API. should happen only once per page load
  initializeYouTubeAPI: =>

    # if Vimeo hasn't been initialized, initialize it.
    unless window.onYouTubeIframeAPIReady
      $.getScript @youTubePlayerApiSrc, @onYouTubeAPIReady
      return

    # must call onYouTubeAPIReady once the current render call stack finishes
    # YouTube API expects the id of a player currently on the page. Backbone may
    # have not yet added the current DOM subtree to the page DOM.
    setTimeout @onYouTubeAPIReady, 0


  onYouTubeAPIReady: =>
    # replace the callback with a no-op
    window.onYouTubeIframeAPIReady = ->

    # wait until the YT.Player class is there
    unless YT.Player
      setTimeout @onYouTubeAPIReady, 100
      return

    # create the player object
    @player = new YT.Player @playerId(), events:

      onReady: =>
        # this *should* initialize the playback at the correct point but
        # doesn't. Need a more robust solution (tick)
        start = parseInt(@model.timeStart() ? 0, 10)

        if @options.autoplay
          @player.loadVideoById(@model.youtubeId(), start)
        else
          @player.cueVideoById(@model.youtubeId(), start)

        @trigger 'PlayerView:Ready'


      onStateChange: (event) =>
        @trigger 'PlayerView:StateChange', @, @player.getPlayerState()



# Register the shell with the acorn object.
acorn.registerShellModule(YouTubeShell)
