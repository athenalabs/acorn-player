goog.provide 'acorn.player.SummaryView'

# Shell.SummaryView -- uniform view to summarize a shell.
# -------------------------------------------------------
#
# +-----------+
# |           |   Title of This Wonderful Shell
# |   thumb   |   A short description of this particular shell.
# |           |   [ action ] [ action ] ...
# +-----------+
#
# The actions are buttons that vary depending on the use-case of the
# SummaryView. The title and description are now overridable functions
# in Shell.

class Shell.SummaryView extends athena.lib.View

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

    @$el.find('#title').text @shell.title()
    @$el.find('#description').text @shell.description()
    @$el.find('#thumbnail').attr 'src', @shell.thumbnailLink()
