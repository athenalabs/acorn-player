`import "mouseTrackingView"`
`import "sliding_object_view"`
`import "sliding_bar_view"`

# TODO: abstract most functionality in ValueSliderView and RangeSliderView into
# a shared parent view

class acorn.player.ValueSliderView extends acorn.player.MouseTrackingView


  className: @classNameExtend 'value-slider-view'


  _targetClassName: => "#{super} value-slider"


  defaults: => _.extend super,
    mouseEventsNamespace: 'valueslider'
    value: 100
    handle: true
    draggable: true
    min: 0
    max: 100


  template: _.template '''
    <div class="<%= targetClassName %>">
      <div class="slider-elements mouse-ignore-targets"></div>
    </div>
    '''


  initialize: =>
    super

    @_value = @options.value
    @_hasHandle = @options.handle

    # initialize value bar
    options =
      low: @options.min
      high: @options.max
      draggable: false # make all value adjustments in-house
      extraClasses: 'value-bar-view'
    @_valueBar = new acorn.player.SlidingBarView options

    # initialize handle
    options =
      location: @_value
      extraClasses: 'slider-handle-view'
      draggable: false # make all value adjustments in-house
    @_handle = new acorn.player.SlidingObjectView options

    # hide handle if undesired
    unless @_hasHandle
      @_handle.$el.addClass 'hidden'

    # listen to mousedown and drag events everywhere
    _.each [@, @_valueBar, @_handle], (view) =>
      @listenTo view, 'MouseTrackingView:MouseDidMousedown', @_onMouseAdjustment
      @listenTo view, 'MouseTrackingView:MouseDidDrag', @_onMouseAdjustment


  render: =>
    super

    @$el.empty()
    @$el.append @template targetClassName: @_targetClassName()

    @$('.slider-elements').first()
      .append(@_valueBar.render().el)
      .append(@_handle.render().el)

    @


  # get or set value
  value: (value, options={}) =>
    if value?
      util.bound value
      unless _.isNaN(value) or value == @_value
        @_value = value
        @_valueBar.values low: 0, high: @_value
        @_handle.location @_value
        unless options.silent
          @trigger 'ValueSliderView:ValueDidChange', @_value

    @_value


  _onMouseAdjustment: =>
    clickLocation =
      # if has handle, get click location with respect to handle center
      if @_hasHandle then @_handle.sliderOptimizedPercentContainerMouseOffset()

      # else get location with respect to slider bar
      else @_percentElementMouseDisplacement offsetFromElement: @$el

    @value clickLocation.x

