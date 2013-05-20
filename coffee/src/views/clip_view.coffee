goog.provide 'acorn.player.ClipView'


class acorn.player.ClipView extends athena.lib.View


  className: @classNameExtend 'clip-view'


  events: => _.extend super,
    'click': (event) =>
      @trigger 'Clip:Click', @
      event.preventDefault()
      false


  defaults: => _.extend super,
    min: 0
    max: Infinity


  render: =>
    super
    @$el.empty()
    @$el.tooltip
      trigger: 'hover'
      title: @model.title

    @reposition()
    @


  values: =>
    start: @model.timeStart
    end: @model.timeEnd


  reposition: =>

    params = (decimalDigits) =>
      low: @options.min
      high: @options.max
      bound: true
      decimalDigits: decimalDigits

    startPercent = util.toPercent @model.timeStart, params()
    endPercent = util.toPercent @model.timeEnd, params()

    @$el.css 'left', startPercent + '%'
    @$el.css 'right', (100 - endPercent) + '%'
