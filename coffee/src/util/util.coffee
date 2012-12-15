goog.provide 'acorn.util'

goog.require 'acorn.config'

acorn.util.assert = (condition, description) ->
  if not condition
    throw new Error(description)

acorn.util.urlRegEx = (url) ->
  ///^(https?:\/\/)?#{url}$///

acorn.util.isUrl = (url) ->
  acorn.util.urlRegEx().test url

# helpers to construct acorn urls TODO: delete these?
acorn.util.url = ->
  path = _.toArray(arguments).join '/'
  "http://#{acorn.config.domain}/#{path}"

acorn.util.apiUrl = ->
  apiPath = "api/v#{acorn.config.api.version}".split '/'
  acorn.util.url.apply(@, apiPath.concat _.toArray arguments)

acorn.util.imgUrl = ->
  acorn.util.url.apply(@, ['img'].concat _.toArray arguments)

# construct an <iframe> element, with `src` and `id`
acorn.util.iframeOptions =
  frameborder: 0
  border: 0
  width: 600
  height: 400
  allowFullScreen: 'true'
  webkitAllowFullScreen: 'true'
  mozallowfullscreen: 'true'
  scrolling: 'no'

# construct an <iframe> element, with `src` and `id`
acorn.util.iframe = (src, id) ->
  f = $ '<iframe>'
  _.map acorn.util.embedIframeOptions, (val, key) ->
    f.attr key, val
  f.attr 'src', src
  f.attr 'id', id if id?
  f

# get the acorn variable in given <iframe> element
acorn.util.acornInIframe = (iframe) ->
  iframe = iframe.get 0 if iframe.jquery?
  win = iframe.contentWindow ? iframe.contentDocument.defaultView
  win.acorn

# creates and returns a get/setter with a closured variable
acorn.util.property = (defaultValue, validate) ->
  storedValue = defaultValue
  validate ?= (x) -> x

  (value) ->
    if value?
      storedValue = validate value
    storedValue

# requests full screen with given elem
acorn.util.fullscreen = (elem) ->
  elem = elem[0] if elem.jquery?
  if elem.requestFullscreen
    elem.requestFullscreen()
  else if elem.webkitRequestFullScreen
    elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)
  else if elem.mozRequestFullScreen
    elem.mozRequestFullScreen()

# add acorn css
acorn.util.appendCss = (srcs) ->
  srcs ?= '/static/css/acorn-player.css'
  srcs = [srcs] unless _.isArray(srcs)
  _.each srcs, (src) ->
    unless $("link[rel='stylesheet'][href='#{src}']").length
      css = $('<link>')
      css.attr 'rel', 'stylesheet'
      css.attr 'href', src
      $('body').append css

# Preserve image aspect ratio but contain it wholly
# See https://github.com/schmidsi/jquery-object-fit
# setTimeout bypasses https://github.com/schmidsi/jquery-object-fit/issues/3
fixObjectFit = ->
  objectFit_ = $.fn.objectFit
  $.fn.objectFit = ->
    args = arguments
    setTimeout (=> objectFit_.apply @, args), 200
    @

fixObjectFit()



# converts human-readable timeString to seconds and back
# human-readable format is: [[hh:]mm:]ss[.SSS]

class acorn.util.Time
  constructor: (time) ->
    @time = @constructor.timestring_to_seconds time

  seconds: => @time
  timestring: => @constructor.timestring_to_seconds @time

  @timestring_to_seconds = (timestring) =>
    timestring = String(timestring ? 0)

    # handle subsec [.SSS]
    [rest, subsec] = timestring.split '.'
    subsec = parseFloat "0.#{subsec ? '0'}"

    # handle [[hh:]mm:]ss
    rest = rest.split(':').reverse()
    [sec, min, hrs] = _.map [0, 1, 2], (n) -> parseInt(rest[n], 10) or 0

    # convert to seconds
    (hrs * 60 * 60) + (min * 60) + sec + subsec

  @seconds_to_timestring = (seconds) =>
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

acorn.util.parseUrl = (url) ->
  # simple `url` validation;
  # should extend to perform more comprehensive tests
  if url == ''
    ValueError 'url', 'should not be the empty string.'

  result = {}

  # trim out any whitespace
  url = $.trim url

  # if no protocol is found, prepend http
  if not /:\/\//.test url
    url = "http://#{url}"

  anchor = document.createElement 'a'
  anchor.href = url

  keys = 'protocol hostname host pathname port search hash href'
  (result[key] = anchor[key]) for key in keys.split ' '

  # port-fix for phantomjs
  if result.port == '0'
    result.port = ''

  result.toString = -> result.href
  result.resource = result.pathname + result.search
  result.extension = result.pathname.split('.').pop()

  result.head = ->
    throw new Error('head not supported. Yet.')

  _.each result, (val, key) ->
    if (not /_$/.test key) and (typeof(val) is 'string')
      result[key + '_'] = val.toLowerCase()

  return result


# -- regular expressions

acorn.util.LINK_REGEX = /// ^
  https?://[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]
///
