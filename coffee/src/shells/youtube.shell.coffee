`import "videolink.shell.js"`
`import "registry"`
`import "../errors"`
`import "../util/"`


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


  defaultAttributes: =>
    superDefaults = super

    _.extend superDefaults,
      title: @_fetchedDefaults?.title or superDefaults.title
      thumbnail: "https://img.youtube.com/vi/#{@youtubeId()}/0.jpg"


  _defaultDescription: =>
    if _.isFinite(@timeStart()) and _.isFinite @timeEnd()
      start = acorn.util.Time.secondsToTimestring @timeStart()
      end = acorn.util.Time.secondsToTimestring @timeEnd()
      clipping = " from #{start} to #{end}"

    "Remix of YouTube video \"#{@_fetchedDefaults?.title ?
        @link()}\"#{clipping ? ''}."


  metaDataUrl: =>
    "https://gdata.youtube.com/feeds/api/videos/#{@youtubeId()}?v=2&alt=jsonc"


  # returns the youtube video id of this link.
  youtubeId: =>
    link = @get('link')

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect youtube link, no video id found.'

    pattern.exec(link)[3]

  parseTime: (time) =>
    validTimePatterns = [
      /(\d+)/
      /(\d+)m(\d+)s/
    ]

    # the second one is more general, work backwards
    match = validTimePatterns[1].exec time
    if match
      return 60 * parseInt(match[1]) + parseInt(match[2])
    match = validTimePatterns[0].exec time
    if validTimePatterns[0].test time
      return parseInt(match[1])
    return undefined

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

  _timeLinkParam: (keys) =>
    unless _.isArray keys
      keys = [keys]
    param = acorn.util.fetchParameters this.model.link(), keys
    return @model.parseTime _.values(param)[0]

  # Default start/end can only be set once player metadata
  # is avaiilable and initialized. Otherwise, default values
  # will override the start/end times.
  initializeDefaultClip: =>
    firstNumber = (args) ->
      _.find args, _.isNumber

    start = firstNumber [
      @model.timeStart()
      @_timeLinkParam ["t", "start"]
      0
    ]

    end = firstNumber [
      @model.timeEnd()
      @_timeLinkParam ["end"]
      @model.timeTotal()
    ]

    end = if end >= start then end else @model.timeTotal()
    # Clip range must be set before progress bar is initialized
    @model.timeStart(start)
    @model.timeEnd(end)
    @_setClipRange()

  onMetaDataSync: (data) =>
    @model._fetchedDefaults ?= {}
    @model._fetchedDefaults = title: data.data.title
    @model._updateAttributesWithDefaults()
    @model.timeTotal data.data.duration

    @initializeDefaultClip()
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


  destroy: =>
    @_seekingMonitor?.destroy()
    super


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


  _seekOffset: (options = {}) =>
    # return target new offset if currently seeking
    if @_seekingMonitor and not options.bypassMonitor
      @_seekingMonitor.newOffset
    else
      @player?.getCurrentTime?() ? 0


  # bridge seekOffsets during asynchronous youtube player seeking
  _monitorSeeking: (seconds) =>
    # config values
    validMargin = 0.3
    interval = 100
    timeout = 5000

    # function to destroy an existing seek monitor
    destroySeekingMonitor = =>
      if @_seekingMonitor
        clearInterval @_seekingMonitor.interval
        clearTimeout @_seekingMonitor.timeout
        delete @_seekingMonitor

    # function to check if a seek has completed
    checkSeekCompletion = =>
      target = @_seekingMonitor.newOffset
      offset = @_seekOffset bypassMonitor: true

      offsetChanged = offset != @_seekingMonitor.oldOffset
      validOffset = target <= offset < target + validMargin
      if offsetChanged and validOffset
        destroySeekingMonitor()

    # create new monitor
    destroySeekingMonitor()
    @_seekingMonitor =
      oldOffset: @_seekOffset()
      newOffset: seconds
      interval: setInterval checkSeekCompletion, interval
      timeout: setTimeout destroySeekingMonitor, timeout
      destroy: destroySeekingMonitor


  _seek: (seconds) =>
    @_monitorSeeking seconds

    # Unless playing, seek first to the wrong place. YouTube's player has a bug
    # such that, when not playing, it occasionally seeks incorrectly (this seems
    # to happen after 2 correct seeks)
    unless @isPlaying()
      wrongPlace = if seconds + 1 < @model.timeTotal()
        seconds + 1
      else
        if seconds - 1 >= 0 then 0 else seconds
      @player?.seekTo?(wrongPlace, true)

    try
      @player?.seekTo?(seconds, true)
    catch error
      console.log error


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
        # This function is broken. It is sufficient to initialize the player
        # using the playerID above.
        # @player.loadVideoById(@model.youtubeId(), start)
        @player.playVideo()
        @player.pauseVideo()
        @player.seekTo(start, true)

        # playing still needs buffering sometimes. hack: play then pause
        @setMediaState 'ready'


      onStateChange: (event) =>
        # track youtube ended state
        @_playerInEndedState = event.data == 0


# Register the shell with the acorn object.
acorn.registerShellModule(YouTubeShell)
