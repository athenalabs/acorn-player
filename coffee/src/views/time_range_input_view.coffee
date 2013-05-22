goog.provide 'acorn.player.TimeRangeInputView'

goog.require 'acorn.player.RangeSliderView'
goog.require 'acorn.player.ProgressRangeSliderView'
goog.require 'acorn.player.TimeInputView'



class acorn.player.TimeRangeInputView extends athena.lib.View


  className: @classNameExtend 'time-range-input-view'


  defaults: => _.extend super,
    min: 0
    max: Infinity
    start: undefined # defaults to min
    end: undefined # defaults to max
    bounceOffset: 10
    SliderView: acorn.player.ProgressRangeSliderView


  template: _.template '''
    <form class="form-inline">
      <div class="start-time-view"></div>
      <div class="total-time-view"></div>
      <div class="end-time-view"></div>
    </form>
    <div class="time-range-slider"></div>
    '''


  _totalTimeTemplate: _.template '''
      <span class="total-time"></span><!-- /<span class="max-time"></span> -->
    '''


  initialize: =>
    super

    # force settings to numbers
    @_min = Number @options.min
    @_max = Number @options.max
    @_start = Number @options.start
    @_end = Number @options.end
    @_progress = Number @options.progress
    @_bounceOffset = Number @options.bounceOffset

    # scrub invalid numbers
    if _.isNaN @_min then @_min = 0
    if _.isNaN @_max then @_max = Infinity
    @_start = if _.isNaN @_start then @_min else @_bound @_start
    @_end = if _.isNaN @_end then @_max else @_bound @_end
    @_progress = if _.isNaN @_progress then @_start else util.bound @_progress,
        {low: @_start, high: @_end}
    if _.isNaN @_bounceOffset then @_bounceOffset = 10

    # scrub slider class option
    SliderView = @options.SliderView
    isOrDerives = athena.lib.util.isOrDerives
    unless isOrDerives SliderView, acorn.player.RangeSliderView
      SliderView = acorn.player.RangeSliderView

    # initialize range slider view
    percentValues = @_percentValues()
    @rangeSliderView = new SliderView
      low: percentValues.start
      high: percentValues.end
      progress: @_percentProgress()

    # initialize start time input view
    @startInputView = new acorn.player.TimeInputView
      name: 'clip start'
      label: 'top'
      value: @_start
      min: @_min
      max: @_max

    # initialize total time input view
    @totalInputView = new acorn.player.TimeInputView
      name: 'clip length'
      label: 'top'
      value: @_end - @_start
      min: @_min
      max: @_max

    # initialize end time input view
    @endInputView = new acorn.player.TimeInputView
      name: 'clip end'
      label: 'top'
      value: @_end
      min: @_min
      max: @_max

    @listenTo @rangeSliderView, 'RangeSliderView:LowValueDidChange',
        @_onRangeSliderLowValueDidChange
    @listenTo @rangeSliderView, 'RangeSliderView:HighValueDidChange',
        @_onRangeSliderHighValueDidChange
    @listenTo @rangeSliderView, 'ProgressRangeSliderView:ProgressDidChange',
        @_onRangeSliderProgressDidChange

    @startInputView.on 'TimeInputView:TimeDidChange', @_onStartInputChanged
    @totalInputView.on 'TimeInputView:TimeDidChange', @_onTotalInputChanged
    @endInputView.on 'TimeInputView:TimeDidChange', @_onEndInputChanged


  destroy: =>
    @rangeInputView.destroy()
    @startInputView.destroy()
    @totalInputView.destroy()
    @endInputView.destroy()
    super


  render: =>
    super

    @$el.empty()
    @$el.append @template()

    @$('.time-range-slider').first().append @rangeSliderView.render().el
    @$('.start-time-view').first().append @startInputView.render().el
    @$('.total-time-view').first().append @totalInputView.render().el
    @$('.end-time-view').first().append @endInputView.render().el
    @reposition()
    @


  reposition: =>
    @_setStartInput()
    @_setEndInput()
    @


  # get/setter for start and end times
  values: (vals, options = {}) =>
    unless @_valuesLocked
      # if resetting, immediately mark start and end as changed
      changed =
        start: !!options.reset
        end: !!options.reset

      start = @_bound vals?.start
      end = @_bound vals?.end

      unless _.isNaN(start) or start == @_start
        @_start = start
        changed.start = true

      unless _.isNaN(end) or end == @_end
        @_end = end
        changed.end = true

      # keep progress bounded by start and end
      progress = util.bound @progress(), {low: @_start, high: @_end}
      unless progress == @progress()
        @_progress = progress
        changed.progress = true

      # change start and/or end as appropriate
      if changed.start or changed.end
        @_change changed

    start: @_start, end: @_end


  # get/setter for progress
  progress: (progress, options = {}) =>
    unless @_valuesLocked
      # if resetting, immediately mark progress as changed
      changed = progress: !!options.reset
      progress = util.bound progress, {low: @_start, high: @_end}

      unless _.isNaN(progress) or progress == @_progress
        @_progress = progress
        changed.progress = true

      # change if appropriate
      if changed.progress
        @_change changed

    @_progress


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


  _percentValues: (vals) =>
    params = (decimalDigits) =>
      low: @_min
      high: @_max
      bound: true
      decimalDigits: decimalDigits

    if athena.lib.util.isStrictObject vals
      if vals.start?
        vals.start = util.fromPercent vals.start, params 1

      if vals.end?
        vals.end = util.fromPercent vals.end, params 1

      vals = _.defaults {}, vals, @values()
      @values vals

    vals = @values()
    start: util.toPercent vals.start, params()
    end: util.toPercent vals.end, params()


  _percentProgress: (progress) =>
    params = (decimalDigits) =>
      low: @_start
      high: @_end
      bound: true

    if progress?
      progress = util.fromPercent progress, params()
      @progress progress

    util.toPercent @progress(), params()


  # focal point for all changes. direct and announce changes to start and/or
  # end times as appropriate
  _change: (changed) =>
    @_setSlider changed

    if changed.start
      @_setStartInput()
      @_setTotalInput()
      @trigger 'TimeRangeInputView:DidChangeStart', @_start

    if changed.end
      @_setEndInput()
      @_setTotalInput()
      @trigger 'TimeRangeInputView:DidChangeEnd', @_end

    if changed.start or changed.end
      @trigger 'TimeRangeInputView:DidChangeTimes', {start: @_start, end: @_end}

    if changed.progress
      @trigger 'TimeRangeInputView:DidChangeProgress', @_progress


  _setStartInput: =>
    @startInputView.value @_start
    percent = Math.max(@_percentValues().start - 12, 0)
    percent = Math.min(percent, 64)
    @$('.form-inline').first().css 'left', percent + '%'


  _setTotalInput: =>
    @totalInputView.value @_end - @_start


  _setEndInput: =>
    @endInputView.value @_end
    percent = Math.max((100 - @_percentValues().end) - 12, 0)
    @$('.form-inline').first().css 'right', percent + '%'


  _setSlider: (changed) =>
    percentValues = @_percentValues()
    percentValues = [percentValues.start, percentValues.end]

    # only send values that changed
    unless changed.start
      percentValues[0] = undefined
    unless changed.end
      percentValues[1] = undefined

    @rangeSliderView.values percentValues

    # always update progress since the percent is a function of start and end
    @rangeSliderView.progress?(@_percentProgress())



  _bound: (val) =>
    util.bound val, {low: @_min, high: @_max}


  # ### Event Handlers

  _onRangeSliderLowValueDidChange: (percentValue) =>
    @_percentValues start: percentValue


  _onRangeSliderHighValueDidChange: (percentValue) =>
    @_percentValues end: percentValue


  _onRangeSliderProgressDidChange: (percentValue) =>
    @_percentProgress percentValue


  _onStartInputChanged: (start) =>
    return if start == @_start

    values =
      start: start
      end: @_end

    # if start has crossed above end, bump end higher
    if @_end < start
      values.end = @_bound start + @_bounceOffset

    @values values


  _onTotalInputChanged: (total) =>
    return if total == (@_end - @_start)

    values =
      start: @_start
      end: @_start + total

    if values.end > @_max
      values.start = @_bound values.start - (values.end - @_max)
      values.end = @_bound values.end

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

