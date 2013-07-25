`import "mouseTrackingView"`



class acorn.player.SlidingObjectView extends acorn.player.MouseTrackingView


  className: @classNameExtend 'sliding-object-view'


  _targetClassName: => "#{super} sliding-object"


  defaults: => _.extend super,
    mouseEventsNamespace: 'slidingobject'
    location: 0
    draggable: true


  template: _.template '''
    <div class="padded-box">
      <div class="<%= targetClassName %>"></div>
    </div>
    '''


  initialize: =>
    super

    # initialize location
    @location @options.location

    @listenTo @, 'SlidingObjectView:DidChangeLocation', @_refreshDisplay


  render: =>
    super
    @$el.empty()

    @$el.append @template targetClassName: @_targetClassName()
    @_slidingObject = @$ '.sliding-object'
    @_refreshDisplay()

    @


  location: (location) =>
    if _.isNumber(location) and not _.isNaN location
      if location < 0 then location = 0
      if location > 100 then location = 100
      @_location = location
      @trigger 'SlidingObjectView:DidChangeLocation', @_location

    @_location


  _refreshDisplay: =>
    if @rendering
      @_slidingObject.css 'left', "#{@_location}%"


  _onMouseDidStart: (event) =>
    @_locationAtMouseStart = @location()


  _onMouseDidDrag: (event) =>
    if @options.draggable
      percentDisplacement = @_percentContainerMouseDisplacement().x
      newLocation = @_locationAtMouseStart + percentDisplacement
      @location newLocation


  _onMouseDidStop: (event) =>
    @_locationAtMouseStart = undefined


  _mouseElement: ($el) =>
    $el ? @_slidingObject


  # get mouse percentage offset from object's sliding area callibrated such that
  # sending the object to this position will center it under the mouse
  sliderOptimizedPercentContainerMouseOffset: =>
    rawPercent = @_percentContainerMouseDisplacement offsetFromElement: true
    objectPOC = @_mouseElementPercentOfContainer()
    x: rawPercent.x - objectPOC.x / 2, y: rawPercent.y - objectPOC.y / 2
