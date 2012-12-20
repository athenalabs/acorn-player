goog.provide 'acorn.shells.VideoLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'


LinkShell = acorn.shells.LinkShell
VideoLinkShell = acorn.shells.VideoLinkShell =

  id: 'acorn.VideoLinkShell'
  title: 'VideoLinkShell'
  description: 'A shell for video links.'
  icon: 'icon-video-link'
  validLinkPatterns: [ acorn.util.urlRegEx('.*\.(avi|mov|wmv)') ]


class VideoLinkShell.Model extends LinkShell.Model

  properties: => _.extend super,
    timeStart: undefined
    timeEnd: undefined
    timeTotal: undefined

  description: =>
    "Seconds #{@timeStart()} to #{@timeEnd()} of video."

  # total possible video time (media length)
  timeTotal: =>
    @timeTotal() ? 0

  # duration of one video loop given current splicing
  duration: =>
    end = @timeEnd() ? @timeTotal()
    end - (@timeStart() ? 0)

  # if metaDataUrl is set, returns a resource to sync and cache custom data
  metaData: =>
    if @metaDataUrl() and not @_metaData
      @_metaData = new athena.lib.util.RemoteResource
        url: @metaDataUrl()
        dataType: 'json'

    @_metaData

  # override with resource URL
  metaDataUrl: => ''





class VideoLinkShell.MediaView extends LinkShell.MediaView

  className: @classNameExtend('video-link-shell')

  initialize: =>
    super
    @timer = new acorn.util.Timer 200, @onPlaybackTick

  render: =>
    super

    @$el.empty()

    # TODO: this embedding method primarily does not work
    @$el.append("<embed src='#{@model.get 'link'}'/>")

    # stop ticking, in case we had been playing and this is a re-render.
    @timer.stopTick()
    @


  duration: => @model.duration()

  # executes periodically to adjust video playback.
  onPlaybackTick: =>
    return unless @isPlaying()

    now = @seekOffset()
    start = @model.timeStart() ? 0
    end = (@model.timeEnd() ? @model.timeTotal()) or Infinity

    # if current playback is behind the start time, seek to start
    @seek(start) if now < start

    # if current playback is after the end time, pause or loop. when looping,
    # set `restarting` flag to avoid decrementing the loop count multiple
    # times before the restart has completed
    if now >= end
      return if @restarting

      loops = @model.get('loops')

      if _.isNumber(loops)
        @looped ?= 0
        @looped++

      if loops == 'infinity' or (_.isNumber(loops) and loops > @looped)
        @seek(start)
        @restarting = true
      else
        @pause()
        @eventhub.trigger('playback:ended')

    else
      @restarting = false



class VideoLinkShell.RemixView extends LinkShell.RemixView

  className: @classNameExtend('video-link-shell')

  events: => _.extend super,
    'change input.start': => @timeInputChanged 'start'
    'blur input.start':  => @timeInputChanged 'start'
    'change input.end': => @timeInputChanged 'end'
    'blur input.end': @onClickLoopsButton
    'click button.loops': @onClickLoopsButton
    'change input.n-loops': @onChangeNLoops
    'blur input.n-loops': @onChangeNLoops

  timeRangeTemplate: _.template('''
    <div class="slider-block">
      <div class="time-slider time fader"></div>
      <div class="total-time time"></div>
    </div>
    <form class="form-inline">
      <div class="control-group time-field time">
        <div class="input-prepend">
          <span class="add-on">start:</span>
          <input size="16" type="text" class="start time-field time">
        </div>
      </div>
      <div class="control-group time-field time">
        <div class="input-prepend">
          <span class="add-on">end:</span>
          <input size="16" type="text" class="end time-field time">
        </div>
      </div>
      <div class="input-prepend input-append loops one-loops">
        <button class="btn loops" type="button">loops:</button>
        <span class="add-on one-loops">1</span>
      </div>
      <div class="input-prepend input-append loops infinity-loops">
        <button class="btn loops" type="button">loops:</button>
        <span class="add-on infinity-loops">∞</span>
      </div>
      <div class="input-prepend loops n-loops">
        <button class="btn loops" type="button">loops:</button>
        <input size="16" type="text" class="n-loops">
      </div>
    </form>
    ''')

  render: =>
    super
    @$el.empty()

    @$el.append(@timeRangeTemplate())
    @setupTimeControls()
    @setupLoopsButton()

    # if meta data is waiting, refresh time controls on retrieval
    @model.metaData()?.sync(success: => @setupTimeControls())

    @

  setupTimeControls: =>
    @changeTimes
      start: @model.timeStart()
      end: @model.timeEnd()

    # TODO: add rangeslider functionality
    # @setupSlider()

  setupSlider: =>
    max = @model.duration()

    # TODO: add rangeslider functionality
    @$('.time-slider').rangeslider(
      min: 0
      max: max
      range: true
      values: [ @model.timeStart() ? 0, @model.timeEnd() ? max]

      slide: (e, ui) =>
        start = ui.values[0]
        end = ui.values[1]
        @changeTimes({start: start, end: end})

      stop: (e, ui) =>
        @eventhub.trigger('change:shell', @model, @)
    )

    @changeTimes
      start: @model.timeStart()
      end: @model.timeEnd()

  setupLoopsButton: =>
    loops = @model.get('loops')

    if loops == undefined
      loops = 'one'
      @model.set('loops', loops)

    switch loops
      when 'one' then @showLoops('one')
      when 'infinity' then @showLoops('infinity')
      else
        # set nLoops value internally and in DOM before showing loop widget
        @nLoops(loops)
        @$('input.n-loops').val(@nLoops())
        @showLoops('n')


  timeInputChanged: (changed) =>
    start = @$('.start').val()
    end = @$('.end').val()

    data =
      start: acorn.util.Time.timestringToSeconds(start)
      end: acorn.util.Time.timestringToSeconds(end)

    # reset invalid input values instead of converting them to 0
    data.start = @model.timeStart() if _.isNaN(parseFloat(start))
    data.end = @model.timeEnd() if _.isNaN(parseFloat(end))

    @changeTimes(data, {lock: changed, updateSlider: true})

    @eventhub.trigger('change:shell', @model, @)

  # Args, contained in a single object:
  # @number start - current start time in seconds
  # @number end - current end time in seconds
  # @string [lock] - name the time nob ('start' or 'end') to lock down if the
  #     times are incompatible (e.g. start = 46, end = 19). by default, start
  #     will be locked
  changeTimes: (data, options) =>
    options ?= {}
    offset = 10
    max = @model.timeTotal() or Infinity

    bound = (val) -> Math.max(0, Math.min((val ? 0), max))

    floatOrDefault = (num, def) ->
      if _.isNumber(num) and not _.isNaN(num) then parseFloat(num) else def

    start = floatOrDefault(data.start, 0)
    end = floatOrDefault(data.end, max)

    start = bound(start)
    end = bound(end)

    # prohibit negative length
    invalidTimes = end < start

    if invalidTimes
      if options.lock == 'end'
        start = bound(end - offset)
      else
        end = bound(start + offset)

      # after rerender(s), display time error
      setTimeout(@timeError, 0)

    secondsToTimestring = acorn.util.Time.secondsToTimestring

    diff = end - start
    time = if isNaN(diff)
      '--'
    else
      secondsToTimestring(diff, {forceMinutes: true})

    @model.set('timeStart', start)
    @model.set('timeEnd', end)

    @$('.start').val(secondsToTimestring(start, {forceMinutes: true}))
    @$('.end').val(secondsToTimestring(end, {forceMinutes: true}))
    @$('.total-time').text(time)

    # TODO: add rangeslider functionality
    # if options.updateSlider or invalidTimes
      # @$('.time-slider').rangeslider(values: [start, end])

  timeError: =>
    # 2 seconds of error display
    timeControls = @$('form').children('.control-group.time-field')
    timeControls.addClass('error')
    setTimeout((-> timeControls.removeClass('error')), 2000)

  nLoops: (n) =>
    # force integer or NaN. avoid interpreting -0.2 as 0 with parseInt
    intN = Math.floor(parseFloat(n))

    @_lastNLoops = intN if intN >= 0
    @_lastNLoops = 2 unless _.isFinite(@_lastNLoops)
    @_lastNLoops

  showLoops: (type) =>
    active = @$("div.#{type}-loops")

    @$('div.loops').addClass('hidden')
    active.removeClass('hidden')

    if @_selectInputOnShow
      active.find('input').select()
      @_selectInputOnShow = false

  onClickLoopsButton: =>
    loops = switch @model.get('loops')
      when 'one' then 'infinity'
      when 'infinity'
        @_selectInputOnShow = true
        @nLoops()
      else 'one'

    @model.set('loops', loops)

    if _.isNumber(loops)
      @$('input.n-loops').val(loops)
      loops = 'n'

    @showLoops(loops)
    @eventhub.trigger('change:shell', @model, @)

  onChangeNLoops: =>
    value = @$('input.n-loops').val()
    newNLoops = @nLoops(value)
    @$('input.n-loops').val(newNLoops)

    if @model.get('loops') != newNLoops
      @model.set('loops', newNLoops)
      @eventhub.trigger('change:shell', @model, @)


# Register the shell with the acorn object.
acorn.registerShellModule(VideoLinkShell)
