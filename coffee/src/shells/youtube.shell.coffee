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
  ]


class YouTubeShell.Model extends VideoLinkShell.Model

  metaDataUrl: =>
    "http://gdata.youtube.com/feeds/api/videos/#{@youtubeId()}?v=2&alt=jsonc"

  description: =>
    "Seconds #{@timeStart()} to #{@timeEnd()} of YouTube video #{@title()}"

  timeTotal: =>
    currTotal = super
    cache = @metaData()

    if cache.synced()
      timeTotal = cache.data().data.duration
      @set('timeTotal', timeTotal) unless currTotal == timeTotal
      timeTotal
    else
      @get('timeTotal') ? 0

  title: =>
    cache = @metaData()
    if cache.synced() then cache.data().data.title else @get('link')

  # returns the youtube video id of this link.
  youtubeId: =>
    link = @get('link')

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect youtube link, no video id found.'

    pattern.exec(link)[3]

  embedLink: =>
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
         '&controls=1'

    # Thumbnail Link can be accessed via:
    # "https://img.youtube.com/vi/#{@youtubeId()}/0.jpg"
    # Use this to set the thumbnail initially in the RemixView. Thumbnail
    # is afterwards entirely changeable by the user (i.e. stored in data).

class YouTubeShell.MediaView extends VideoLinkShell.MediaView

  className: @classNameExtend('youtube-shell')

  render: =>
    super
    @$el.empty()

    # initialize YouTube setup and add the YouTube player iframe
    @onYTInitialize()
    link = @model.embedLink()
    @$el.append(acorn.util.iframe(link, 'ytplayer'))

    @

  play: => @ytplayer?.playVideo()

  pause: => @ytplayer?.pauseVideo()

  isPlaying: => @ytplayer?.getPlayerState() == YT.PlayerState.PLAYING

  seek: (seconds) => @ytplayer?.seekTo(seconds, true)

  seekOffset: => @ytplayer?.getCurrentTime() ? 0


  # YouTube API - communication between the YouTube iframe API and the shell.
  # see https://developers.google.com/youtube/iframe_api_reference

  youtubePlayerApiSrc: 'http://www.youtube.com/iframe_api'

  # initialize youtube API. initialization should happen only once per page load
  onYTInitialize: =>
    if window.onYouTubeIframeAPIReady
      # YT API expects the id of a player currently on the page. Backbone may
      # have not yet added the current DOM subtree to the page DOM.
      setTimeout @onYTReady, 0

    else
      # setup YT ready callback and include the YouTubePlayerAPI code
      window.onYouTubeIframeAPIReady = @onYTReady

      script = $('<script>').attr('src', @youtubePlayerApiSrc)
      $('body').append(script)

  onYTReady: =>
    @ytplayer = new YT.Player 'ytplayer', events:
      onReady: @onYTPlayerReady
      onStateChange: @onYTPlayerStateChange

    # replace the callback with a no-op
    window.onYouTubeIframeAPIReady = ->

  onYTPlayerReady: =>
    # this *should* initialize the playback at the correct point but doesn't.
    # Need a robust solution (tick)
    start = parseInt(@model.get('time_start') ? 0, 10)

    if @options.autoplay
      @ytplayer.loadVideoById(@model.youtubeId(), start)
    else
      @ytplayer.cueVideoById(@model.youtubeId(), start)

  onYTPlayerStateChange: (event) =>
    if @isPlaying() then @timer.startTick() else @timer.stopTick()


class YouTubeShell.RemixView extends VideoLinkShell.RemixView

  className: @classNameExtend('youtube-shell')


# Register the shell with the acorn object.
acorn.registerShellModule(YouTubeShell)
