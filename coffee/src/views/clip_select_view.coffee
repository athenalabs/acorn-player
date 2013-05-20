goog.provide 'acorn.player.ClipSelectView'

goog.require 'acorn.player.TimeRangeInputView'


class acorn.player.ClipSelectView extends athena.lib.View


  className: @classNameExtend 'clip-select-view'


  events: => _.extend super,
    'click .clip-highlight-view': => @toggleActive true


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

    @$('.clip-highlight-view').tooltip
      trigger: 'hover'
      title: 'Edit Clip'

    @


  _activeClass: 'clip-select-active'


  # when active, time input show, highlighted section hides
  toggleActive: (active) =>
    active ?= !@$el.hasClass @_activeClass
    @_adjustHighlightSize()
    if active
      @$el.addClass @_activeClass
      @$('.clip-highlight-view').tooltip 'hide'
    else
      @$el.removeClass @_activeClass


  # use the clip sizes to adjust the highlighted section size
  _adjustHighlightSize: =>
    percents = @inputView._percentValues()
    $highlight = @$('.clip-highlight-view')
    $highlight.css 'left', percents.start + '%'
    $highlight.css 'right', (100 - percents.end) + '%'
    @


  # get/setter for start and end times
  values: =>
    @inputView.values arguments
