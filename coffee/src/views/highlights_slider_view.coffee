goog.provide 'acorn.player.HighlightsSliderView'

goog.require 'acorn.player.ValueSliderView'


class acorn.player.HighlightsSliderView extends acorn.player.ValueSliderView


  className: @classNameExtend 'highlights-slider-view'


  _targetClassName: => "#{super} highlights-slider"


  defaults: => _.extend super,
    highlights: []


  initialize: =>
    super

    @highlights = @options.highlights


  render: =>
    super

    @$el.empty()
    @$el.append @template targetClassName: @_targetClassName()

    @$('.slider-elements').first()
      .append(@_valueBar.render().el)
      .append(@_handle.render().el)

    _.each @highlights, (highlight) =>
      @$('.slider-elements').first().append highlight.render().el

    @_repositionHighlights()
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


  _sortHighlights: =>
    @highlights = _.sortBy @highlights, (highlight) =>
      highlight.values().start


  # returns the index of the best row for a given highlight.
  _rowForHighlight: (rows, highlight) =>
    start = highlight.values().start
    row = _.find rows, (row) =>
      _.last(row).values().end <= start
    row && _.indexOf rows, row


  _repositionHighlights: =>
    @_sortHighlights()

    rows = []

    # place each highlight in a row.
    _.each @highlights, (highlight) =>
      row = @_rowForHighlight rows, highlight

      # no suitable row? add one.
      unless row >= 0
        row = rows.length
        rows.push []

      # add the highlight to the row
      rows[row].push highlight

      # adjust the highlight offset from top
      highlight.$el.css 'top', row * 9

    # adjust entire slider bar height
    height = (rows.length * 9 - 1)
    @$el.css 'height', height
    @$('.sliding-bar').first().css 'height', height
    @$('.slider-handle-view .sliding-object').first().css 'height', height + 6
