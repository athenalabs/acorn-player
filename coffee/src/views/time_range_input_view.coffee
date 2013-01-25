goog.provide 'acorn.player.TimeRangeInputView'

goog.require 'acorn.player.TimeInputView'



class acorn.player.TimeRangeInputView extends athena.lib.View


  className: @classNameExtend 'time-range-input-view'


  template: _.template '''
    <div class="slider-block">
      <div class="slider-wrapper">
        <div class="time-slider time"></div>
      </div>
    </div>
    <form class="form-inline">
      <div class="time-inputs"></div>
      <div class="total-time-view">
        <span class="total-time"></span>/<span class="max-time"></span>
      </div>
    </div>
    '''


  _totalTimeTemplate: _.template '''
    '''


  initialize: =>
    super

    @_min = @options.min ? 0
    @_max = @options.max ? Infinity
    @_start = @_bound @options.start ? @_min
    @_end = @_bound @options.end ? @_max
    @_bounceOffset = @options.bounceOffset ? 10

    # initialize start time input view
    @startInputView = new acorn.player.TimeInputView
      name: 'start:'
      value: @_start
      min: @_min
      max: @_max

    # initialize end time input view
    @endInputView = new acorn.player.TimeInputView
      name: 'end:'
      value: @_end
      min: @_min
      max: @_max

    @startInputView.on 'change:time', @_onStartInputChanged
    @endInputView.on 'change:time', @_onEndInputChanged


  destroy: =>
    @startInputView.destroy()
    @endInputView.destroy()
    super


  render: =>
    super

    @$el.empty()
    @$el.append @template()

    @$('.time-inputs').append @startInputView.render().el
    @$('.time-inputs').append @endInputView.render().el

    @_renderSlider()
    @_setTotalTime()

    # Rangeslider takes time to expand itself, and its handles cannot be
    # positioned properly until it has done so. For now, reset values on the
    # slider after 0.2 seconds.
    setTimeout @_setSlider, 200

    @


  # set up a jQuery UI rangeslider widget
  _renderSlider: =>
    @$('.time-slider').rangeslider
      min: @_min
      max: @_max
      values: [@_start, @_end]
      slide: (e, ui) =>
        start = ui.values[0]
        end = ui.values[1]
        @_onSliderChanged {start: start, end: end}


  # get/setter for start and end times
  values: (vals, options = {}) =>
    unless @_valuesLocked
      changed = {}
      start = @_bound vals?.start
      end = @_bound vals?.end

      unless _.isNaN(start) or start == @_start
        @_start = start
        changed.start = true

      unless _.isNaN(end) or end == @_end
        @_end = end
        changed.end = true

      if options.reset
        changed.start = changed.end = true

      # change start and/or end as appropriate
      if changed.start or changed.end
        @_change changed

    start: @_start, end: @_end


  setMin: (min) =>
    if _.isNumber(min) and not (_.isNaN(min) or @_min == min)
      @_min = min
      @_reset()


  setMax: (max) =>
    if _.isNumber(max) and not (_.isNaN(max) or @_max == max)
      @_max = max
      @_reset()


  _reset: =>
    # lock values while changing min and max
    @_valuesLocked = true

    # set min and max
    @startInputView.setMin @_min
    @startInputView.setMax @_max
    @endInputView.setMin @_min
    @endInputView.setMax @_max

    # unlock values
    @_valuesLocked = undefined

    # scrub values
    values = @values()
    values =
      start: @_bound values.start ? @_min
      end: @_bound values.end ? @_max

    # force reset all values
    @values values, reset: true


  # focal point for all changes. direct and announce changes to start and/or
  # end times as appropriate
  _change: (changed) =>
    if changed.start
      @_setStartInput()
      @trigger 'change:start', @_start

    if changed.end
      @_setEndInput()
      @trigger 'change:end', @_end

    @_setSlider()
    @_setTotalTime()
    @trigger 'change:times', {start: @_start, end: @_end}


  _setStartInput: =>
    @startInputView.value @_start


  _setEndInput: =>
    @endInputView.value @_end


  _setSlider: =>
    @$('.time-slider').rangeslider values: [@_start, @_end]


  _setTotalTime: =>
    timestring = acorn.util.Time.secondsToTimestring

    time = @_end - @_start
    time = if _.isNaN time then '--' else timestring time
    @$('.total-time').text time
    @$('span.max-time').text acorn.util.Time.secondsToTimestring @_max


  _bound: (val) =>
    Math.max @_min, Math.min(val, @_max)


  # ### Event Handlers

  _onStartInputChanged: (start) =>
    return if start == @_start

    values =
      start: start
      end: @_end

    # if start has crossed above end, bump end higher
    if @_end < start
      values.end = @_bound start + @_bounceOffset

    @values values


  _onEndInputChanged: (end) =>
    return if end == @_end

    values =
      start: @_start
      end: end

    # if end has crossed below end, bump start lower
    if end < @_start
      values.start = @_bound end - @_bounceOffset

    @values values


  _onSliderChanged: (vals) =>
    @values vals

