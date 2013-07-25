`import "value_slider_view"`
`import "clip_group_view"`

class acorn.player.HighlightsSliderView extends acorn.player.ValueSliderView


  className: @classNameExtend 'highlights-slider-view'


  _targetClassName: => "#{super} highlights-slider"


  defaults: => _.extend super,
    highlights: []


  initialize: =>
    super

    @highlights = @options.highlights

    @clipGroupView = new acorn.player.ClipGroupView
      eventhub: @eventhub
      clips: @highlights


  render: =>
    super

    @$el.empty()
    @$el.append @template targetClassName: @_targetClassName()

    @$('.slider-elements').first()
      .append(@_valueBar.render().el)
      .append(@_handle.render().el)
      .append(@clipGroupView.render().el)

    height = @clipGroupView.$el.css 'height'
    @$el.css 'height', height
    @$('.sliding-bar').first().css 'height', height
    @$('.slider-handle-view .sliding-object').first().css 'height', height + 6

    @


  # get or set value
  value: (value) =>
    if value?
      util.bound value
      unless _.isNaN(value) or value == @_value
        @_value = value
        @_valueBar.values low: 0, high: @_value
        @_handle.location @_value
        @trigger 'ValueSliderView:ValueDidChange', @_value

    @_value
