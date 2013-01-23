goog.provide 'acorn.util'

goog.require 'acorn.config'



util = acorn.util


util.assert = (condition, description) ->
  throw new Error description if not condition


util.urlRegEx = (url) ->
    # temporary. should move away from using urlRegEx this way:
    if url
      return ///(https?:\/\/)?#{url ? '.*'}///

    # john gruber's URL regex
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls

    ///
    ^
    (                       # Capture 1: entire matched URL
      (?:
        https?://               # http or https protocol
        |                       #   or
        www\d{0,3}[.]           # "www.", "www1.", "www2." … "www999."
        |                           #   or
        [a-z0-9.\-]+[.][a-z]{2,4}/  # looks like domain name followed by a slash
      )
      (?:                       # One or more:
        [^\s()<>]+                  # Run of non-space, non-()<>
        |                           #   or
        \(([^\s()<>]+|(\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
      )+
      (?:                       # End with:
        \(([^\s()<>]+|(\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
        |                               #   or
        [^\s`!()\[\]{};:'".,<>?«»“”‘’]        # not a space or punct char
      )
    )
    $
    ///


util.isUrl = (url) ->
  url = String(url)
  @urlRegEx().test url


util.isPath = (path) ->
  /^[A-Za-z\/.-_]+$/.test path


# helpers to construct acorn urls TODO: delete these?
util.url = ->
  path = _.toArray(arguments).join '/'
  "//#{acorn.config.domain}/#{path}"


util.apiUrl = ->
  apiPath = "api/v#{acorn.config.api.version}".split '/'
  @url.apply(@, apiPath.concat _.toArray arguments)


util.imgUrl = ->
  @url.apply(@, ['img'].concat _.toArray arguments)


# fixes given url (or fragment) to be more correct
util.urlFix = (url) ->
  # return blank/falsy urls
  unless url
    return url

  unless /^([a-z0-9]+:)?\/\//i.test url
    url = "http://#{url}"

  url


# construct an <iframe> element, with `src` and `id`
util.iframeOptions =
  frameborder: 0
  border: 0
  width: '100%'
  height: '100%'
  allowFullScreen: 'true'
  webkitAllowFullScreen: 'true'
  mozallowfullscreen: 'true'
  # needed for iris, but breaks youtube flash. put in an IrisShell:
  # sandbox: 'allow-forms allow-same-origin allow-scripts allow-top-navigation'


# construct an <iframe> element, with `src` and `id`
util.iframe = (src, id) ->
  f = $ '<iframe>'
  _.map @iframeOptions, (val, key) ->
    f.attr key, val
  f.attr 'src', src
  f.attr 'id', id if id?
  f


# get the acorn variable in given <iframe> element
util.acornInIframe = (iframe) ->
  iframe = iframe.get 0 if iframe.jquery?
  win = iframe.contentWindow ? iframe.contentDocument.defaultView
  win.acorn


# creates and returns a get/setter with a closured variable
util.property = (defaultValue, validate) ->
  storedValue = defaultValue
  validate ?= (x) -> x

  (value) ->
    storedValue = validate value if value?
    storedValue


# requests full screen with given elem
util.fullscreen = (elem) ->
  $(elem).fullScreen()


# add acorn css
util.appendCss = (srcs) ->
  srcs ?= acorn.config.css
  srcs = [srcs] unless _.isArray(srcs)
  _.each srcs, (src) ->
    unless $("link[rel='stylesheet'][href='#{src}']").length
      css = $('<link>')
      css.attr 'rel', 'stylesheet'
      css.attr 'href', src
      $('body').append css


# check if element is in the DOM
# inspired by StackOverflow: http://stackoverflow.com/questions/5629684/
util.elementInDom = (element) ->
  if element instanceof $
    return _.all $elements, util.elementInDom

  while element = element?.parentNode
    if element == document
      return true

  return false


# Originally from StackOverflow
# http://stackoverflow.com/questions/736513
util.parseUrl = (url) ->
  # simple `url` validation
  # should extend to perform more comprehensive tests
  ValueError 'url', 'should not be the empty string.' if url == ''

  result = {}

  # trim out any whitespace
  url = $.trim url

  # if no protocol is found, prepend http
  url = "http://#{url}" unless /^([a-z0-9]+:)?\/\//i.test url

  anchor = document.createElement 'a'
  anchor.href = url

  keys = 'protocol hostname host pathname port search hash href'
  (result[key] = anchor[key]) for key in keys.split ' '

  # port-fix for phantomjs
  result.port = '' if result.port == '0'

  result.toString = -> result.href
  result.resource = result.pathname + result.search
  result.extension = result.pathname.split('.').pop()

  result.head = -> throw new Error('head not supported. Yet.')

  _.each result, (val, key) ->
    if (not /_$/.test key) and (typeof(val) is 'string')
      result[key + '_'] = val.toLowerCase()

  result



# track mouse location at all times
util.mouseLocationTracker = (->
  id = 0
  subscribed = []
  tracker =
    x: undefined
    y: undefined
    active: false

  onMousemove = (e) ->
    tracker.x = e.pageX
    tracker.y = e.pageY

  startTracking = ->
    tracker.active = true
    $(document).on 'mousemove.mouseLocationTracker', onMousemove

  stopTracking = ->
    tracker.active = false
    tracker.x = undefined
    tracker.y = undefined
    $(document).off 'mousemove.mouseLocationTracker', onMousemove

  # subscribe to tracker to ensure it activates
  tracker.subscribe = () ->
    unless tracker.active
      startTracking()
    subscribed.push id
    id++

  # unsubscribe id when done for efficiency
  tracker.unsubscribe = (id) ->
    subscribed = _.without subscribed, id
    if subscribed.length == 0
      stopTracking()

  tracker
)()



# converts human-readable timestring to seconds and back
# human-readable format is: [[hh:]mm:]ss[.SSS]
class util.Time


  constructor: (time, @options = {}) ->
    @time = @constructor.timestringToSeconds time


  seconds: => @time
  timestring: => @constructor.secondsToTimestring @time, @options


  @timestringToSeconds: (timestring) =>
    timestring = String(timestring ? 0)

    # handle subsec [.SSS]
    [rest, subsec] = timestring.split '.'
    subsec = parseFloat "0.#{subsec ? '0'}"

    # handle [[hh:]mm:]ss
    rest = rest.split(':').reverse()
    [sec, min, hrs] = _.map [0, 1, 2], (n) -> parseInt(rest[n], 10) or 0

    # convert to seconds
    (hrs * 60 * 60) + (min * 60) + sec + subsec


  @secondsToTimestring: (seconds, options = {}) =>
    sec = parseInt seconds, 10

    hrs = parseInt sec / (60 * 60), 10
    sec -= hrs * 60 * 60

    min = parseInt sec / 60, 10
    sec -= min * 60

    subsec = seconds % 1
    if subsec
      subsec = Math.round(subsec * 1000) / 1000
      subsec = String(subsec).substr 1, 4 # remove first 0
      subsec = subsec.replace /0+$/, ''

    hrs = if hrs == 0 then '' else "#{hrs}:"
    pad = (n) -> if n < 10 then "0#{n}" else "#{n}"

    if hrs == '' and options.padTime == false
      if min == 0 then min = '' else min = "#{min}:"
    else
      min = "#{pad min}:"

    unless min == ''
      sec = pad sec

    "#{hrs}#{min}#{sec}#{subsec or ''}"



class util.Timer


  constructor: (@interval, @callback, @args) ->
    @callback ?= ->
    @args ?= []
    @args = [@args] unless _.isArray @args


  startTick: =>
    @stopTick()
    @intervalObject = setInterval @onTick, @interval


  stopTick: =>
    if @intervalObject
      clearInterval @intervalObject
      @intervalObject = undefined


  onTick: =>
    @callback @args...



# -- regular expressions

util.LINK_REGEX = /// ^
    https?://[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]
  ///



# -- jQuery utils

# Preserve image aspect ratio but contain it wholly
# See https://github.com/schmidsi/jquery-object-fit
# setTimeout bypasses https://github.com/schmidsi/jquery-object-fit/issues/3
util.fixObjectFit = ->
  objectFit_ = $.fn.objectFit
  $.fn.objectFit = ->
    console.log 'Object Fit currently disabled.'
    # setTimeout (=> objectFit_.apply @, arguments), 200
    @

util.fixObjectFit()


# inserts element at specific index
$.fn.insertAt = (index, element) ->
  lastIndex = @children().size()

  # negative indices wrap
  if index < 0
    index = Math.max(0, lastIndex + 1 + index) if index < 0

  @append element

  # move into position
  if index < lastIndex
    @children().eq(index).before(@children().last())

  @
