`import "clip_view"`


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

    _.defer @_repositionClips
    @


  _sortClips: =>
    @clips.sort (clipA, clipB) =>
      clipA.values().start - clipB.values().start


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

    clipHeight = (Number(@clips[0]?.$el.height()) || 7) + 2
    rows = @_rowsForClips @clips

    # place each clip in a row.
    for row in [0..rows.length]

      # adjust the clip offset from top
      _.each rows[row], (clip) =>
        clip.$el.css 'bottom', row * clipHeight


    # adjust entire slider bar height
    height = (rows.length * clipHeight - 1)
    @$el.css 'height', height
