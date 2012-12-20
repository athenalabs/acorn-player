goog.provide 'acorn.util'

goog.require 'acorn.config'


util = acorn.util

util.assert = (condition, description) ->
  throw new Error description if not condition

util.urlRegEx = (url) ->
    ///^(https?:\/\/)?#{url ? '.*'}$///

util.isUrl = (url) ->
  url = String(url)
  @urlRegEx().test url

util.isPath = (path) ->
  /^[A-Za-z\/.-_]+$/.test path

# helpers to construct acorn urls TODO: delete these?
util.url = ->
  path = _.toArray(arguments).join '/'
  "http://#{acorn.config.domain}/#{path}"

util.apiUrl = ->
  apiPath = "api/v#{acorn.config.api.version}".split '/'
  @url.apply(@, apiPath.concat _.toArray arguments)

util.imgUrl = ->
  @url.apply(@, ['img'].concat _.toArray arguments)

# construct an <iframe> element, with `src` and `id`
util.iframeOptions =
  frameborder: 0
  border: 0
  width: '100%'
  height: '100%'
  allowFullScreen: 'true'
  webkitAllowFullScreen: 'true'
  mozallowfullscreen: 'true'

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
  elem = elem[0] if elem.jquery?
  if elem.requestFullscreen
    elem.requestFullscreen()
  else if elem.webkitRequestFullScreen
    elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)
  else if elem.mozRequestFullScreen
    elem.mozRequestFullScreen()

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

# converts human-readable timestring to seconds and back
# human-readable format is: [[hh:]mm:]ss[.SSS]
class util.Time
  constructor: (time) ->
    @time = @constructor.timestringToSeconds time

  seconds: => @time
  timestring: => @constructor.secondsToTimestring @time

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

  @secondsToTimestring: (seconds) =>
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

    "#{hrs}#{pad min}:#{pad sec}#{subsec or ''}"

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
  url = "http://#{url}" unless /:\/\//.test url

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
    setTimeout (=> objectFit_.apply @, arguments), 200
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
