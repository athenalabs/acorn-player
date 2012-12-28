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
    "Vimeo video #{@title()} from #{start} to #{end}."


  timeTotal: =>
    currTotal = super
    cache = @metaData()

    if cache.synced()
      timeTotal = cache.data()[0].duration
      @set('timeTotal', timeTotal) unless currTotal == timeTotal
      return timeTotal

    currTotal ? 0


  title: =>
    cache = @metaData()
    if cache.synced() then cache.data().data.title else @get('link')


  # returns the vimeo video id of this link.
  vimeoId: =>
    link = @link()

    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link

    unless pattern then ValueError 'Incorrect youtube link, no video id found.'

    pattern.exec(link)[5]


  embedLink: =>
    # see http://developer.vimeo.com/player/embedding
    "http://player.vimeo.com/video/#{@vimeoId()}?" +
      '&byline=0' +
      '&portrait=0' +
      '&api=1' +
      '&player_id=vimeoplayer' +
      '&title=0' +
      '&byline=1' +
      '&portrait=0' +
      '&color=ffffff'



class VimeoShell.MediaView extends VideoLinkShell.MediaView


  className: @classNameExtend 'vimeo-shell'



class VimeoShell.RemixView extends VideoLinkShell.RemixView


  className: @classNameExtend 'vimeo-shell'



class VimeoShell.PlayerView extends VideoLinkShell.PlayerView


  className: @classNameExtend 'vimeo-shell'


  initialize: =>
    super
    @_isPlaying = false
    @_timeTotal = undefined
    @_seekOffset = 0


  render: =>
    super
    @$el.empty()
    @$el.append acorn.util.iframe @model.embedLink(), 'vimeoplayer'
    @initializeVimeo()
    @


  # Control the player


  play: =>
    @player.api 'play'


  pause: =>
    @player.api 'pause'


  seek: (seconds) =>
    @player.api 'seekTo', [seconds.toString()]


  isPlaying: =>
    @_isPlaying


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
    @player = Froogaloop @$('#vimeoplayer')[0]
    @player.addEvent 'ready', @onVimeoPlayerReady
    # @play()


  onVimeoPlayerReady: =>
    # attach callbacks to the vimeo player.

    @player.addEvent 'pause', =>
      @_isPlaying = false
      @trigger 'PlayerView:StateChange'

    @player.addEvent 'play', =>
      @_isPlaying = true
      @trigger 'PlayerView:StateChange'


    @player.addEvent 'playProgress', (params) =>
      @_timeTotal = parseFloat params.duration
      @_seekOffset = parseFloat params.seconds
      @_isPlaying = true

    @trigger 'PlayerView:Ready'





# Register the shell with the acorn object.
acorn.registerShellModule VimeoShell
