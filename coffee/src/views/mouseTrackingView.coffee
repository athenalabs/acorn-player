goog.provide 'acorn.player.MouseTrackingView'


# Adapted from jQueryUI's $.ui.mouse widget - thanks jQuery!



class acorn.player.MouseTrackingView extends athena.lib.View


  className: @classNameExtend 'mouse-tracking-view'


  _targetClassName: => 'mouse-target'


  defaults: => _.extend super,
    mouseMinimumDistance: 1
    mouseMinimumDelay: 0

    # The namespace appended to global event bindings for disambiguation
    # purposes. Not related to events fired by MouseTrackingView.
    mouseEventsNamespace: 'mousetracking'


  events: => _.extend super,
    # ignore all clicks inside a mouse-ignore element and mouse-target clicks
    # inside a mouse-ignore-targets element
    'mousedown .mouse-ignore': @_onMousedownIgnore
    'mousedown .mouse-ignore .mouse-target': @_onMousedownIgnore
    'mousedown .mouse-ignore-targets .mouse-target': @_onMousedownIgnore

    'mousedown .mouse-target': @_onMousedownMouseTarget
    'click .mouse-target': @_onClickMouseTarget
    'mouseenter .mouse-target': @_onMouseenterMouseTarget
    'mouseleave .mouse-target': @_onMouseleaveMouseTarget


  template: _.template '''
    <div class="<%= targetClassName %>"></div>
    '''

  initialize: =>
    super

    # ensure mouse location is tracked
    @_mouseLocationTrackerId = util.mouseLocationTracker.subscribe()

    @listenTo @, 'MouseTrackingView:MouseDidMousedown', @_onMouseDidMousedown
    @listenTo @, 'MouseTrackingView:MouseDidStart', @_onMouseDidStart
    @listenTo @, 'MouseTrackingView:MouseDidDrag', @_onMouseDidDrag
    @listenTo @, 'MouseTrackingView:MouseDidStop', @_onMouseDidStop
    @listenTo @, 'MouseTrackingView:MouseDidMouseup', @_onMouseDidMouseup
    @listenTo @, 'MouseTrackingView:MouseDidClick', @_onMouseDidClick
    @listenTo @, 'MouseTrackingView:MouseDidMouseenter', @_onMouseDidMouseenter
    @listenTo @, 'MouseTrackingView:MouseDidMouseleave', @_onMouseDidMouseleave


  destroy: =>
    super

    # unsubscribe from mouse location tracker
    util.mouseLocationTracker.unsubscribe @_mouseLocationTrackerId

    # remove global event bindings in case mousedown is active
    $(document).off "mousemove.#{@mouseEventsNamespace}", @_onMouseMove
    $(document).off "mouseup.#{@mouseEventsNamespace}", @_onMouseUp


  render: =>
    super
    @$el.empty()
    @$el.append @template targetClassName: @_targetClassName()
    @


  # Mouse tracking logic - overriding in child classes is not recommended
  # ---------------------------------------------------------------------

  _onMousedownIgnore: (event) =>
    @_mousedownIgnoreEvent = event


  _onMousedownMouseTarget: (event) =>
    # Click event may never have fired (Gecko & Opera)
    @_preventClickEvent = false

    # we may have missed mouseup (out of window)
    @_mouseStarted && @_onMouseUp event

    # only respond to left-clicks
    unless event.which == 1
      return

    if event == @_mousedownIgnoreEvent
      return

    @_mousedownEvent = event
    @_mousedownTarget().addClass 'mouse-is-down'
    @trigger 'MouseTrackingView:MouseDidMousedown', event

    # reset mouse delay flag
    @_mouseDelayAchieved = false

    if @_mouseMinimumDistanceMet(event) and @_mouseMinimumDelayMet event
      # abort if disabled
      if @_preventMouseStart event
        return
      else
        @_mouseStarted = true
        @trigger 'MouseTrackingView:MouseDidStart', event, @_mousedownEvent

    # don't select text and other page elements when dragging
    event.preventDefault()

    $(document).on "mousemove.#{@mouseEventsNamespace}", @_onMouseMove
    $(document).on "mouseup.#{@mouseEventsNamespace}", @_onMouseUp


  _onMouseMove: (event) =>
    # IE mouseup check - mouseup may have happened when mouse was out of window
    ie = !!/msie [\w.]+/.exec navigator.userAgent.toLowerCase()
    if (ie and (!document.documentMode or document.documentMode < 9) and
        !event.button) then return @_onMouseUp event

    if @_mouseStarted
      @trigger 'MouseTrackingView:MouseDidDrag', event, @_mousedownEvent
      return

    if @_mouseMinimumDistanceMet(event) and @_mouseMinimumDelayMet event
      # abort if disabled
      if @_preventMouseStart @_mousedownEvent, event
        @_onMouseUp event
        return

      @_mouseStarted = true
      @trigger 'MouseTrackingView:MouseDidStart', event, @_mousedownEvent
      @trigger 'MouseTrackingView:MouseDidDrag', event, @_mousedownEvent


  _onMouseUp: (event) =>
    # clean up global listeners and lingering timeouts
    $(document).off "mousemove.#{@mouseEventsNamespace}", @_onMouseMove
    $(document).off "mouseup.#{@mouseEventsNamespace}", @_onMouseUp
    clearTimeout @_mouseDelayCountdown

    if @_mouseStarted
      @_mouseStarted = false

      if @_mousedownTarget()[0] == @_mousedownEvent.target
        @_preventClickEvent = true

      @trigger 'MouseTrackingView:MouseDidStop', event, @_mousedownEvent

    @trigger 'MouseTrackingView:MouseDidMouseup', event, @_mousedownEvent
    @_mousedownTarget().removeClass 'mouse-is-down'
    @_mousedownEvent = undefined


  _onClickMouseTarget: (event) =>
    if @_preventClickEvent
      @_preventClickEvent = false
      event.stopImmediatePropagation()
      return false
    else
      @trigger 'MouseTrackingView:MouseDidClick', event


  _onMouseenterMouseTarget: (event) =>
    @trigger 'MouseTrackingView:MouseDidMouseenter', event


  _onMouseleaveMouseTarget: (event) =>
    @trigger 'MouseTrackingView:MouseDidMouseleave', event


  # Mouse start governors
  # ---------------------

  # return a truthy value to block a mousestart (override as desired)
  _preventMouseStart: (mousedownEvent, event) =>


  _mouseMinimumDistanceMet: (event) =>
    {x, y} = @_mouseDisplacement()
    distance = Math.sqrt(x * x + y * y)
    distance >= @options.mouseMinimumDistance


  _mouseMinimumDelayMet: (event) =>
    delay = @options.mouseMinimumDelay
    if delay > 0 and not @_mouseDelayAchieved
      @_mouseDelayCountdown = setTimeout (=> @_mouseDelayAchieved = true), delay
      false
    else
      true


  # Mouse event handlers - override in child classes as desired
  # -----------------------------------------------------------

  _onMouseDidMousedown: (event) =>

  _onMouseDidStart: (event, mousedownEvent) =>

  _onMouseDidDrag: (event, mousedownEvent) =>

  _onMouseDidStop: (event, mousedownEvent) =>

  _onMouseDidMouseup: (event, mousedownEvent) =>

  _onMouseDidClick: (event) =>

  _onMouseDidMouseenter: (event) =>

  _onMouseDidMouseleave: (event) =>


  # Mouse target utilities
  # ----------------------

  _mousedownTarget: () =>
    el = @_mousedownEvent?.target
    if el? then $ el else undefined


  _mouseElement: ($el) =>
    $ $el ? @_mousedownTarget() ? @$('.mouse-target').first()


  _mouseElementContainer: ($el) =>
    @_mouseElement($el).offsetParent()


  _mouseElementDimensions: ($el) =>
    $el = @_mouseElement $el
    width: $el.width(), height: $el.height()


  _mouseElementContainerDimensions: ($el) =>
    container = @_mouseElementContainer $el
    width: container.width(), height: container.height()


  _mouseElementPercentOfContainer: ($el, $containerEl) =>
    # get element and container dimensions
    el = @_mouseElementDimensions $el
    if $containerEl?
      container = @_mouseElementDimensions $containerEl
    else
      container = @_mouseElementContainerDimensions $el

    # calculate percents
    x: el.width * 100 / container.width, y: el.height * 100 / container.height


  # Mouse position utilities
  # ------------------------

  # uses element width and height - considers basic box model and is ignorant
  # of border-radius
  _mouseInElementBox: ($el, dimension) =>
    $el = $ $el
    offset = @_mouseOffsetFromElement $el
    inWidth = 0 <= offset.x <= $el.outerWidth()
    inHeight = 0 <= offset.y <= $el.outerHeight()
    if dimension == 'x' or dimension == 'width' then inWidth
    else if dimension == 'y' or dimension == 'height' then inHeight
    else inWidth and inHeight


  _mouseOffsetFromElement: ($el) =>
    $el = $ $el
    x = util.mouseLocationTracker.x - $el.offset().left
    y = util.mouseLocationTracker.y - $el.offset().top
    x: x, y: y


  # current mouse position x and y displacement from coordinates; uses mousedown
  # event by default
  _mouseDisplacement: (initial = @_mousedownEvent) =>
    dx = util.mouseLocationTracker.x - (initial?.pageX ? initial?.x)
    dy = util.mouseLocationTracker.y - (initial?.pageY ? initial?.y)
    x: dx, y: dy


  _percentMouseDisplacement: (options = {}) =>
    startEvent = options.startEvent ? @_mousedownEvent
    dimensionsFn = options.dimensionsFn ? @_mouseElementContainerDimensions

    # get $el conditionally since startEvent can be undefined if getting offset
    el = options.$el ? options.el ? startEvent?.target
    $el = $ el if el?

    # calculate dimensions from $el, but use options dimensions when available
    calculatedDimensions = dimensionsFn $el
    width = options.width ? calculatedDimensions.width
    height = options.height ? calculatedDimensions.height

    # get coordinate difference from mouse location
    {x, y} =
      if _$el = options.offsetFromElement
        _$el = if util.elementInDom(_$el) then _$el else $el
        @_mouseOffsetFromElement _$el
      else
        @_mouseDisplacement startEvent

    # calculate and return percent changes against width and height
    x: (x * 100 / width), y: (y * 100 / height)


  _percentElementMouseDisplacement: (options = {}) =>
    options = _.clone options
    options.dimensionsFn = @_mouseElementDimensions
    @_percentMouseDisplacement options


  _percentContainerMouseDisplacement: (options = {}) =>
    options = _.clone options
    options.dimensionsFn = @_mouseElementContainerDimensions

    # by default, percentOffset should get offset from container, not element
    if (_$el = options.offsetFromElement)? and not util.elementInDom _$el
      $el = options.$el ? options.el ? options.startEvent?.target
      options.offsetFromElement = @_mouseElementContainer $el

    @_percentMouseDisplacement options
