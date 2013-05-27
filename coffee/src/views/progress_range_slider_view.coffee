goog.provide 'acorn.player.ProgressRangeSliderView'

goog.require 'acorn.player.RangeSliderView'
goog.require 'acorn.player.SlidingBarView'



class acorn.player.ProgressRangeSliderView extends acorn.player.RangeSliderView


  className: @classNameExtend 'progress-range-slider-view'


  _targetClassName: => "#{super} progress-range-slider"


  defaults: => _.extend super,
    mouseEventsNamespace: 'progressrangeslider'
    progress: 0
    draggableBar: false


  initialize: =>
    super

    # initialize progress bar
    options =
      value: @options.progress
      draggable: true
      handle: false
      extraClasses: 'progress-bar-view'
    @_progressBar = new acorn.player.ValueSliderView options

    # add progress bar as an internal view to range bar
    @_rangeBar.internalViews = @_progressBar

    # listen to mousedown and drag events
    @listenTo @_progressBar, 'ValueSliderView:ValueDidChange',
        @_onProgressBarValueDidChange


  _onProgressBarValueDidChange: (value) =>
    @progress value


  # get or set low-to-high ordered values (public)
  progress: (progress, options={}) =>
    if progress?
      util.bound progress
      unless _.isNaN(progress)
        @_progressBar.value progress, options
        unless options.silent
          @trigger 'ProgressRangeSliderView:ProgressDidChange', progress

    @_progressBar.value()
