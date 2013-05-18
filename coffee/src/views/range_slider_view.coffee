goog.provide 'acorn.player.RangeSliderView'

goog.require 'acorn.player.MouseTrackingView'
goog.require 'acorn.player.SlidingObjectView'
goog.require 'acorn.player.SlidingBarView'


# TODO: abstract most functionality in ValueSliderView and RangeSliderView into
# a shared parent view

class acorn.player.RangeSliderView extends acorn.player.MouseTrackingView


  className: @classNameExtend 'range-slider-view'


  _targetClassName: => "#{super} range-slider"


  defaults: => _.extend super,
    mouseEventsNamespace: 'rangeslider'
    low: 0
    high: 100
    draggableBar: true


  template: _.template '''
    <div class="<%= targetClassName %>">
      <div class="slider-elements mouse-ignore-targets"></div>
    </div>
    '''


  initialize: =>
    super

    # initialize values
    @_values = [@options.low, @options.high]

    # initialize handles
    values = @_handleOrderedValues()
    @_handles = _.map [0..1], (i) =>
      # construct ith handle with ith value
      handle = new acorn.player.SlidingObjectView
        location: values[i]
        extraClasses: ['slider-handle-view']

      # pass handle index to listener
      @listenTo handle, 'SlidingObjectView:DidChangeLocation', =>
         @_onHandleDidChangeLocation i, arguments...

      handle


    # initialize range bar
    values = @_magnitudeOrderedValues()
    options =
      low: values[0]
      high: values[1]
      draggable: @options.draggableBar
      extraClasses: 'range-bar-view'

    @_rangeBar = new acorn.player.SlidingBarView options
    @listenTo @_rangeBar, 'SlidingBarView:DidChangeValues',
      @_onRangeBarDidChangeValues


  render: =>
    super

    @$el.empty()
    @$el.append @template targetClassName: @_targetClassName()

    @$('.slider-elements')
      .append(@_rangeBar.render().el)
      .append(@_handles[0].render().el)
      .append(@_handles[1].render().el)
    @


  # get or set low-to-high ordered values (public)
  values: (values) =>
    if values?
      # ensure values is an array
      sortedValues =
        if _.isArray values then values
        else if _.isObject values then [values.low, values.high]
        else if arguments.length > 1 then [arguments...]
        else [values, values]

      @_magnitudeOrderedValues sortedValues

    @_magnitudeOrderedValues()


  # get or set handle-ordered values
  _handleOrderedValues: (values) =>
    if _.isArray values
      oldMovs = @_magnitudeOrderedValues()

      # adjust handle values
      for i in [0..1]
        # sanitize value
        value = util.bound values[i]

        # mark if changed
        unless _.isNaN(value) or value == @_values[i]
          @_values[i] = value
          @_handles[i].location value

      # if values changed, adjust range bar and trigger events
      newMovs = @_magnitudeOrderedValues()
      unless oldMovs[0] == newMovs[0] and oldMovs[1] == newMovs[1]
        @_rangeBar.values newMovs

        unless oldMovs[0] == newMovs[0]
          @trigger 'RangeSliderView:LowValueDidChange', newMovs[0]

        unless oldMovs[1] == newMovs[1]
          @trigger 'RangeSliderView:HighValueDidChange', newMovs[1]

        @trigger 'RangeSliderView:ValuesDidChange', @values()

    _.clone @_values


  # get or set low-to-high ordered values
  _magnitudeOrderedValues: (values) =>
    if _.isArray values
      hovs = @_handleOrderedValues()
      movs = @_magnitudeOrderedValues()

      # flip values order if handle order is inverted
      unless hovs[0] == movs[0] and hovs[1] == movs[1]
        values = [values[1], values[0]]

      @_handleOrderedValues values

    @_magnitudeSort @_handleOrderedValues()


  _magnitudeSort: (arr) =>
    arr.sort (a,b) -> a - b


  _onHandleDidChangeLocation: (index, location) ->
    newValues = Array 2
    newValues[index] = location
    @_handleOrderedValues newValues


  _onRangeBarDidChangeValues: (values) ->
    @values [values.low, values.high]


  _onMouseDidMousedown: (event) =>
    # get click location with respect to handle centers
    clickLocation = @_handles[0].sliderOptimizedPercentContainerMouseOffset().x

    # handle distances from click
    handleLocations = @_handleOrderedValues()
    distance = [
      Math.abs handleLocations[0] - clickLocation
      Math.abs handleLocations[1] - clickLocation
    ]

    # change value of closer handle
    @_closerHandleIndex = if distance[0] < distance[1] then 0 else 1
    newValues = Array 2
    newValues[@_closerHandleIndex] = clickLocation
    @_handleOrderedValues newValues


  _onMouseDidStart: (event) =>
    @_valuesAtMouseStart = @_handleOrderedValues()


  _onMouseDidDrag: (event) =>
    # calculate new value
    percentDisplacement = @_percentElementMouseDisplacement().x
    newValue = @_valuesAtMouseStart[@_closerHandleIndex] + percentDisplacement

    newValues = Array 2
    newValues[@_closerHandleIndex] = newValue
    @_handleOrderedValues newValues


  _onMouseDidStop: (event) =>
    @_valuesAtMouseStart = undefined


  _onMouseDidMouseup: (event) =>
    @_closerHandleIndex = undefined
