`import "sliding_object_view"`


class acorn.player.SlidingBarView extends acorn.player.SlidingObjectView


  className: @classNameExtend 'sliding-bar-view'


  _targetClassName: => "#{super} sliding-bar"


  defaults: => _.extend super,
    mouseEventsNamespace: 'slidingbar'
    low: 0
    high: 100
    internalViews: []


  template: _.template '''
    <div class="<%= targetClassName %>">
      <div class="internal-views mouse-ignore-targets"></div>
    </div>
    '''


  initialize: =>
    super

    # initialize low and high values
    @values @options

    @internalViews = @options.internalViews

    @listenTo @, 'SlidingBarView:DidChangeValues', @_refreshDisplay


  render: =>
    super

    # array-ify internalViews if necessary; do this in render in case
    # @internalViews is set directly by an external entity
    unless _.isArray @internalViews
      @internalViews = [@internalViews]

    # append internal views to sliding bar
    internalViewsDiv = @$el.children().children '.internal-views'
    for view in @internalViews
      if view instanceof Backbone.View
        internalViewsDiv.append view.render().el
      else
        console.log 'WARNING: SlidingBarView only supports internalViews derived
            from Backbone.View'

    @


  # disable location method - use values instead
  location: =>


  _values: (values) =>
    changes = {}

    # adjust low value if changed
    if values?.low? and values.low != @_low
      @_low = values.low
      changes.low = true

    # adjust high value if changed
    if values?.high? and values.high != @_high
      @_high = values.high
      changes.high = true

    # report changes
    if changes.low? or changes.high?
      values = @_values()

      @trigger 'SlidingBarView:DidChangeValues', values

      if changes.low
        @trigger 'SlidingBarView:DidChangeLowValue', values.low

      if changes.high
        @trigger 'SlidingBarView:DidChangeHighValue', values.high

    # return current low and high values
    {low: @_low, high: @_high}


  values: (values) =>
    if _.isObject values
      _values = @_values()

      # extract low and high values
      if _.isArray values
        [val0, val1] = values
        low = Math.min val0, val1
        high = Math.max val0, val1
      else
        low = values.low
        high = values.high

      unless _.isNumber(low) and not _.isNaN low
        low = undefined
      unless _.isNumber(high) and not _.isNaN high
        high = undefined

      # bound valid values between 0 and 100
      if low < 0 then low = 0
      if low > 100 then low = 100
      if high < 0 then high = 0
      if high > 100 then high = 100

      # change current low value if a valid and new low value is passed in
      if low? and low != _values.low
        _values.low = low

        # bound high value against low value
        if _values.high < _values.low
          _values.high = _values.low

      # change current high value if a valid and new high value is passed in
      if high? and high != _values.high
        _values.high = high

        # bound low value against high value
        if _values.high < _values.low
          _values.low = _values.high

      # set new values
      @_values _values

    @_values()


  _refreshDisplay: =>
    # override entirely - do not call super

    unless @rendering
      return

    values = @values()
    @_slidingObject.css 'left', "#{values.low}%"
    @_slidingObject.css 'right', "#{100 - values.high}%"


  _onMouseDidStart: (event) =>
    @_valuesAtMouseStart = @values()


  _onMouseDidDrag: (event) =>
    if @options.draggable
      options = $el: @_slidingObject
      percentDisplacement = @_percentContainerMouseDisplacement options
      low = @_valuesAtMouseStart.low + percentDisplacement.x
      high = @_valuesAtMouseStart.high + percentDisplacement.x

      # bound slider movement within its container
      adjustment =
        if low < 0 then 0 - low
        else if high > 100 then 100 - high
        else 0

      low += adjustment
      high += adjustment

      @values low: low, high: high


  _onMouseDidStop: (event) =>
    @_valuesAtMouseStart = undefined
