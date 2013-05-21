goog.provide 'acorn.player.ClipSelectView'

goog.require 'acorn.player.TimeRangeInputView'


class acorn.player.ClipSelectView extends athena.lib.View


  className: @classNameExtend 'clip-select-view'


  events: => _.extend super,
    'click .clip-highlight-view': =>
      @toggleActive true
      event.preventDefault()
      false


  defaults: => _.extend super,
    min: 0
    max: Infinity
    start: undefined # defaults to min
    end: undefined # defaults to max


  template: _.template '''
    <div class="clip-highlight-view"></div>
    '''


  initialize: =>
    super

    @inputView = new acorn.player.TimeRangeInputView
      eventhub: @eventhub
      min: @options.min
      max: @options.max
      start: @options.start
      end: @options.end
      bounceOffset: 10
      SliderView: acorn.player.ProgressRangeSliderView

    # proxy inputView events
    @listenTo @inputView, 'all', => @trigger arguments


  # @listenTo @inputView, 'TimeRangeInputView:DidChangeTimes', @_adjustHighlight

  destroy: =>
    @inputView.destroy()
    super


  render: =>
    super
    @$el.empty()
    @$el.html @template()
    @$el.append @inputView.render().el
    @toggleActive false

    @$('.clip-highlight-view').first().tooltip
      trigger: 'hover'
      title: 'Edit Clip'

    @


  _activeClass: 'clip-select-active'


  # when active, time input show, highlighted section hides
  toggleActive: (active) =>
    active ?= !@$el.hasClass @_activeClass
    @_adjustSize active
    if active
      @$el.addClass @_activeClass
      @$('.clip-highlight-view').first().tooltip 'hide'
      @trigger 'ClipSelect:Active', @
    else
      @$el.removeClass @_activeClass
      @trigger 'ClipSelect:Inactive', @


  # use the clip sizes to adjust the highlighted section size
  _adjustSize: (active) =>
    if active
      @$el.css 'left', 0
      @$el.css 'right', 0
    else
      percents = @inputView._percentValues()
      @$el.css 'left', percents.start + '%'
      @$el.css 'right', (100 - percents.end) + '%'
    @


  # get/setter for start and end times
  values: =>
    @inputView.values arguments
