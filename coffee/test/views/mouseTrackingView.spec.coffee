goog.provide 'acorn.specs.views.MouseTrackingView'

goog.require 'acorn.player.MouseTrackingView'

describe 'acorn.player.MouseTrackingView', ->

  MouseTrackingView = acorn.player.MouseTrackingView
  EventSpy = athena.lib.util.test.EventSpy

  util = athena.lib.util
  test = util.test
  xdescribe = test.xdescribe
  xit = test.xit


  defaultOpts = ->
    eventhub: _.extend {}, Backbone.Events

  # construct a new mouse tracking view and receive pointers to the view and its
  # mouse-target element
  setupMTV = (opts) =>
    opts = _.defaults (opts ? {}), defaultOpts()
    mtv = new MouseTrackingView opts
    mtv.render()
    target = mtv.$ '.mouse-target'
    [mtv, target]


  it 'should be part of acorn.player', ->
    expect(MouseTrackingView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView MouseTrackingView, athena.lib.View, defaultOpts(), ->

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      # container css
      container = $('<div>')
        .height(240)
        .width('100%')
        .css('margin', 20)
        .css('position', 'relative')
        .css('background-color', '#DDD')
        .css('overflow', 'hidden')

      # add to the DOM to see how it looks
      [mtv, target] = setupMTV location: 20

      # make some extra targets
      targets = [target]
      makeTarget = -> mtv.template targetClassName: mtv._targetClassName()
      for i in [0...5]
        target = $ makeTarget()
        targets.push target
        mtv.$el.append target

      # target css
      for target, i in targets
        target
          .height(15 + 5 * i)
          .width(40 - 5 * i)
          .css('position', 'absolute')
          .css('background-color', '#555')

      # helper function
      bound = (n, max) ->
        if n < 0 then 0
        else if n > max then max
        else n

      actions = []

      # target[0] - change colors depending on state
      actions.push
        down: (event) ->
          @started = false
          clearTimeout @_delayedReset
          targets[0].css 'background-color', '#E44'

        start: (event, mdEvent) ->
          @started = true

        drag: (event, mdEvent) ->
          targets[0].css 'background-color', '#393'

        stop: (event, mdEvent) ->
          targets[0].css 'background-color', '#939'
          unless mtv._mouseInElementBox targets[0]
            targets[0].height(@initialDims.height).width @initialDims.width

        up: (event, mdEvent) ->
          reset = () =>
            targets[0].css 'background-color', '#555'
            unless mtv._mouseInElementBox targets[0]
              targets[0].height(@initialDims.height).width @initialDims.width

          if @started then @delayedReset = setTimeout reset, 600 else reset()
          @started = false

        click: (event) ->
        enter: (event) ->
          @initialDims ?= height: targets[0].height(), width: targets[0].width()
          targets[0].height(@initialDims.width * 2).width @initialDims.width * 2

        leave: (event) ->
          unless @started
            targets[0].height(@initialDims.height).width @initialDims.width

      # target[1] - slide horizontally
      actions.push
        down: (event) ->
          # prepare for movement
          @initialLeft = parseFloat targets[1].css 'left'
          @initialTop = parseFloat targets[1].css 'top'
          unless @range
            targetDims = mtv._mouseElementDimensions targets[1]
            containerDims = mtv._mouseElementContainerDimensions targets[1]
            @range =
              width: containerDims.width - targetDims.width
              height: containerDims.height - targetDims.height

        start: (event, mdEvent) ->
        drag: (event, mdEvent) ->
          # move in 1D
          displacement = mtv._mouseDisplacement()
          newLeft = bound @initialLeft + displacement.x, @range.width
          targets[1].css 'left', newLeft

        stop: (event, mdEvent) ->
        up: (event, mdEvent) ->
        click: (event) ->
        enter: (event) ->
        leave: (event) ->

      # target[2] - move around, change color intensity with speed
      actions.push
        down: (event) ->
          # set up color
          @hexValue ?= 0x55

          # prepare for movement
          @initialLeft = parseFloat targets[2].css 'left'
          @initialTop = parseFloat targets[2].css 'top'
          unless @range
            targetDims = mtv._mouseElementDimensions targets[2]
            containerDims = mtv._mouseElementContainerDimensions targets[2]
            @range =
              width: containerDims.width - targetDims.width
              height: containerDims.height - targetDims.height

        start: (event, mdEvent) ->
          targets[2].css 'border', '1px solid #555'

        drag: (event, mdEvent) ->
          # increase color
          @hexValue += 8
          color = =>
            hex = @hexValue.toString 16
            targets[2].css 'background-color', "##{hex}#{hex}#{hex}"
          color()

          # reduce color in 600ms
          setTimeout (=> (@hexValue -= 8) and color()), 600

          # move in 2D
          displacement = mtv._mouseDisplacement()
          newLeft = bound @initialLeft + displacement.x, @range.width
          newTop = bound @initialTop + displacement.y, @range.height
          targets[2].css 'left', newLeft
          targets[2].css 'top', newTop

        stop: (event, mdEvent) ->
          targets[2].css 'border', 0

        up: (event, mdEvent) ->
        click: (event) ->
        enter: (event) ->
        leave: (event) ->

      # target[3] - crosshairs on mousedown
      actions.push
        setup: ->
          targets[3].css 'z-index', 1

          @lines = [
            @mainVertical = @makeLine 1, '100%', mtv.$el
            @mainHorizontal = @makeLine '100%', 1, mtv.$el
            @innerVertical = @makeLine 1, '100%', targets[3]
            @innerHorizontal = @makeLine '100%', 1, targets[3]
          ]

        makeLine: (w, h, container) ->
          $('<div>')
            .css('position', 'absolute')
            .width(w)
            .height(h)
            .appendTo(container)

        positionLines: (event) ->
          mainOffset = mtv._mouseOffsetFromElement container
          innerOffset = mtv._mouseOffsetFromElement targets[3]

          @mainVertical.css 'left', mainOffset.x
          @mainHorizontal.css 'top', mainOffset.y
          @innerVertical.css 'left', innerOffset.x
          @innerHorizontal.css 'top', innerOffset.y

          # hide inner lines except when crosshairs pass through target
          if mtv._mouseInElementBox targets[3], 'x'
            @innerVertical.removeClass 'hidden'
          else
            @innerVertical.addClass 'hidden'

          if mtv._mouseInElementBox targets[3], 'y'
            @innerHorizontal.removeClass 'hidden'
          else
            @innerHorizontal.addClass 'hidden'

          # reset target highlights
          for highlight in @inTargetHighlights ? []
            highlight.remove()
          @inTargetHighlights = []

          for target in targets
            if mtv._mouseInElementBox target
              offset = mtv._mouseOffsetFromElement target
              vertical = @makeLine(3, '100%', target)
                .css('left', offset.x - 1)
                .css('background-color', 'rgba(98, 255, 249, 0.5)')
              horizontal = @makeLine('100%', 3, target)
                .css('top', offset.y - 1)
                .css('background-color', 'rgba(98, 255, 249, 0.5)')
              @inTargetHighlights.push vertical, horizontal

          m = ->
            @innerVertical.css 'border-left', '1px solid rgb(64, 136, 133)'
            @innerVertical.css 'border-right', '1px solid rgb(64, 136, 133)'
            @innerHorizontal.css 'border-top', '1px solid rgb(64, 136, 133)'
            @innerHorizontal.css 'border-bottom', '1px solid rgb(64, 136, 133)'

          color = if @inTargetHighlights.length > 0
            'rgb(98, 255, 249)'
          else
            'rgba(255, 103, 103, 0.5)'

          line.css 'background-color', color for line in @lines

        down: (event) ->
          # setup if first time
          unless @lines
            @setup()

          # un-hide lines and position
          line.removeClass 'hidden' for line in @lines
          @positionLines event

        start: (event, mdEvent) ->
        drag: (event, mdEvent) ->
          @positionLines event

        stop: (event, mdEvent) ->
        up: (event, mdEvent) ->
          line.addClass 'hidden' for line in @lines ? []
          for highlight in @inTargetHighlights ? []
            highlight.remove()

        click: (event) ->
        enter: (event) ->
        leave: (event) ->

      # target[4] - slide vertically
      actions.push
        down: (event) ->
          # prepare for movement
          @initialTop = parseFloat targets[4].css 'top'
          unless @range
            targetDims = mtv._mouseElementDimensions targets[4]
            containerDims = mtv._mouseElementContainerDimensions targets[4]
            @range = height: containerDims.height - targetDims.height

        start: (event, mdEvent) ->
        drag: (event, mdEvent) ->
          # move in 1D
          displacement = mtv._mouseDisplacement()
          newTop = bound @initialTop + displacement.y, @range.height
          targets[4].css 'top', newTop

        stop: (event, mdEvent) ->
        up: (event, mdEvent) ->
        click: (event) ->
        enter: (event) ->
        leave: (event) ->

      # target[5] - slide horizontally, shoot on click
      actions.push
        fire: (projectile, distance) ->
          _distance = 0
          up = (projectile) ->
            projectile.css 'bottom', _distance++
            if _distance < distance
              setTimeout (-> up projectile), 3
            else
              projectile.remove()
          up projectile

        down: (event) ->
          # prepare for movement
          @initialLeft = parseFloat targets[5].css 'left'
          @initialTop = parseFloat targets[5].css 'top'
          unless @range
            targetDims = mtv._mouseElementDimensions targets[5]
            containerDims = mtv._mouseElementContainerDimensions targets[5]
            @range =
              width: containerDims.width - targetDims.width
              height: containerDims.height - targetDims.height

        start: (event, mdEvent) ->
        drag: (event, mdEvent) ->
          # move in 1D
          displacement = mtv._mouseDisplacement()
          newLeft = bound @initialLeft + displacement.x, @range.width
          targets[5].css 'left', newLeft

        stop: (event, mdEvent) ->
        up: (event, mdEvent) ->
        click: (event) ->
          rand = -> (Math.floor Math.random() * 257).toString(16)
          targetLeft = parseFloat targets[5].css 'left'
          targetDims = mtv._mouseElementDimensions targets[5]
          containerDims = mtv._mouseElementContainerDimensions targets[5]

          projectile = $('<div>')
            .height(10)
            .width(10)
            .css('position', 'absolute')
            .css('left', targetLeft + targetDims.width / 2 - 5)
            .css('border-radius', 5)
            .css('background-color', "##{rand()}#{rand()}#{rand()}")
            .appendTo(container)

          @fire projectile, containerDims.height

        enter: (event) ->
        leave: (event) ->

      # forward to correct handler based on target and event type
      forward = (eventType, args) ->
        console.log eventType
        mouseTarget = switch eventType
          when 'click', 'enter', 'leave' then args[0].target
          else mtv._mousedownTarget()[0]
        for target, i in targets
          idx = i if target[0] == mouseTarget or target[0] == $(mouseTarget).parent()[0]
        actions[idx][eventType] args...

      # bind events
      pref = 'MouseTrackingView:MouseDid'
      mtv.on "#{pref}Mousedown", (event) -> forward 'down', arguments
      mtv.on "#{pref}Start", (event, mdEvent) -> forward 'start', arguments
      mtv.on "#{pref}Drag", (event, mdEvent) -> forward 'drag', arguments
      mtv.on "#{pref}Stop", (event, mdEvent) -> forward 'stop', arguments
      mtv.on "#{pref}Mouseup", (event, mdEvent) -> forward 'up', arguments
      mtv.on "#{pref}Click", (event) -> forward 'click', arguments
      mtv.on "#{pref}Mouseenter", (event) -> forward 'enter', arguments
      mtv.on "#{pref}Mouseleave", (event) -> forward 'leave', arguments

      # add to DOM
      $player.append container.append mtv.el

      # set initial target positions based on container dimensions
      for target, i in targets
        target
          .css('top', container.height() / 6 * i)
          .css('left', container.width() / 6 * i)


    xdescribe 'MouseTrackingView: thorough tests', ->
