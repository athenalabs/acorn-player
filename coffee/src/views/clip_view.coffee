goog.provide 'acorn.player.ClipView'


class acorn.player.ClipView extends athena.lib.View


  className: @classNameExtend 'clip-view'


  template: _.template '''
    <div class="clip-note tooltip-inner"><%= title %></div>
    '''

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
    @$el.html @template @model
    @reposition()
    @


  # use different class since both can happen independently.
  popupNote: =>
    @$el.addClass('popup-note')
    _.delay (=> @$el.removeClass('popup-note')), 3000


  showNote: =>
    @$el.addClass('show-note')


  hideNote: =>
    @$el.removeClass('show-note')


  values: =>
    start: @model.timeStart
    end: @model.timeEnd


  isActive: =>
    @$el.hasClass 'active'


  setActive: (active) =>
    active ?= !@isActive()
    if active
      unless @isActive()
        @popupNote()
      @$el.addClass 'active'
    else
      @$el.removeClass 'active'


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
