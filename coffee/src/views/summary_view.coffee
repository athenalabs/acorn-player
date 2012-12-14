goog.provide 'acorn.player.SummaryView'

# uniform view to summarize an acorn or shell.
#
# +-----------+
# |           |   Title of This Wonderful Thing
# |   thumb   |   A short description of this particular thing.
# |           |   [ action ] [ action ] ...
# +-----------+
#
# The actions are buttons that vary depending on the use-case of the
# SummaryView. The title and description are now overridable functions
# in Shell.

class acorn.player.SummaryView extends athena.lib.View

  className: @::className + ' acorn-shell-summary'

  template: _.template '''
    <img id="thumbnail" />
    <div class="thumbnailside">
      <div id="title"></div>
      <div id="description"></div>
      <div id="buttons"></div>
    </div>
    '''

  render: =>
    @$el.empty()
    @$el.html @template()

    @$('#title').text @shell.title()
    @$('#description').text @shell.description()
    @$('#thumbnail').attr 'src', @shell.thumbnailLink()

    @
