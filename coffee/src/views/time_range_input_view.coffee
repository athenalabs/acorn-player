goog.provide 'acorn.player.TimeRangeInputView'



class acorn.player.TimeRangeInputView extends athena.lib.View


  className: @classNameExtend 'time-range-input-view'


  template: _.template '''
    <div class="slider-block">
      <div class="time-slider time"></div>
      <div class="total-time time"></div>
    </div>
    <form class="form-inline"></div>
    '''


  initialize: =>
    super

    @_min = @options.min ? 0
    @_max = @options.max ? Infinity
    @_start = @options.start ? @_min
    @_end = @options.end ? @_max
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

    @$('form').append @startInputView.render().el
    @$('form').append @endInputView.render().el
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
  values: (vals) =>
    changed = {}

    if vals?.start? and vals.start != @_start
      @_start = vals.start
      changed.start = true

    if vals?.end? and vals.end != @_end
      @_end = vals.end
      changed.end = true

    # change start and/or end as appropriate
    if changed.start or changed.end
      @_change changed

    start: @_start, end: @_end


  setMin: (min) =>
    return unless _.isNumber(min) and !_.isNaN min

    @_min = min
    @startInputView.setMin @_min
    @endInputView.setMin @_min
    @$('.time-slider').rangeslider min: @_min


  setMax: (max) =>
    return unless _.isNumber(max) and !_.isNaN max

    @_max = max
    @startInputView.setMax @_max
    @endInputView.setMax @_max
    @$('.time-slider').rangeslider max: @_max


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


  _bound: (val) =>
    Math.max(@_min, Math.min((val ? 0), @_max))


  # ### Event Handlers

  _onStartInputChanged: (start) =>
    return if start == @_start

    @_start = start
    changed = start: true

    # if start has crossed above end, bump end higher
    if @_end < @_start
      @_end = @_bound(@_start + @_bounceOffset)
      changed.end = true

    @_change changed


  _onEndInputChanged: (end) =>
    return if end == @_end

    @_end = end
    changed = end: true

    # if end has crossed below start, bump start lower
    if @_end < @_start
      @_start = @_bound(@_end - @_bounceOffset)
      changed.start = true

    @_change changed


  _onSliderChanged: (vals) =>
    @values vals

