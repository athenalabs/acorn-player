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

    # toolbar buttons
    toolbarButtons: [
      # {
      #   id:'Link',
      #   icon: 'icon-link',
      #   tooltip: 'Copy link to this Highlight'
      #   className: 'btn-small btn-inverse'
      # }
    ]


  initialize: =>
    super

    @toolbarView = new athena.lib.ToolbarView
      eventhub: @eventhub
      buttons: @options.toolbarButtons
      extraClasses: ['btn-group']

    @toolbarView.on 'all', =>
      unless /Toolbar:Click:/.test arguments[0]
        return
      @trigger 'Clip:' + arguments[0], @



  render: =>
    super
    @$el.empty()
    @$el.html @template @model
    @$el.append @toolbarView.render().el
    @reposition()
    @


  # use different class since both can happen independently.
  popupNote: =>
    @$el.addClass('popup-note')
    _.delay (=> @$el.removeClass('popup-note')), 3000
    @reposition()


  showNote: =>
    @$el.addClass('show-note')
    @reposition()


  hideNote: =>
    @$el.removeClass('show-note')


  values: (newValues) =>
    @model.timeStart = newValues.start if newValues?.start?
    @model.timeEnd = newValues.end if newValues?.end?

    if @rendering
      @reposition()

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

    # reposition horizontally
    params = (decimalDigits) =>
      low: @options.min
      high: @options.max
      bound: true
      decimalDigits: decimalDigits

    startPercent = util.toPercent @model.timeStart, params()
    endPercent = util.toPercent @model.timeEnd, params()

    @$el.css 'left', startPercent + '%'
    @$el.css 'right', (100 - endPercent) + '%'

    # reposition toolbar
    height = Math.max(@$('.clip-note').height() + 15)
    @toolbarView.$el.css 'bottom', height + 14
