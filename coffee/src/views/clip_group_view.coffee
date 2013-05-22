goog.provide 'acorn.player.ClipGroupView'

goog.require 'acorn.player.ClipView'


class acorn.player.ClipGroupView extends athena.lib.View


  className: @classNameExtend 'clip-group-view'


  initialize: =>
    super
    @clips = @options.clips


  render: =>
    super

    @$el.empty()
    _.each @clips, (clip) =>
      @$el.append clip.render().el

    @_repositionClips()
    @


  _sortClips: =>
    @clips = _.sortBy @clips, (clip) =>
      clip.values().start


  # returns the index of the best row for a given clip.
  _rowForClip: (rows, clip) =>
    start = clip.values().start
    row = _.find rows, (row) =>
      _.last(row).values().end <= start
    row && _.indexOf rows, row


  # returns the clip row construction.
  _rowsForClips: (clips) =>

    rows = []

    # place each clip in a row.
    _.each clips, (clip) =>
      row = @_rowForClip rows, clip

      # no suitable row? add one.
      unless row >= 0
        row = rows.length
        rows.push []

      # add the clip to the row
      rows[row].push clip

    rows


  _repositionClips: =>
    @_sortClips()

    rows = @_rowsForClips @clips

    # place each clip in a row.
    for row in [0..rows.length]

      # adjust the clip offset from top
      _.each rows[row], (clip) =>
        clip.$el.css 'top', row * 9


    # adjust entire slider bar height
    height = (rows.length * 9 - 1)
    @$el.css 'height', height
