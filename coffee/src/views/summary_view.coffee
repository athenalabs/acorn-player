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


  className: @classNameExtend 'summary-view row-fluid'


  template: _.template '''
    <div class="thumbnail-view span2">
      <img class="img-rounded" src="" />
    </div>
    <div class="span10">
      <div class="title"></div>
      <div class="description"></div>
      <div class="buttons"></div>
    </div>
    '''


  initialize: =>
    super
    @listenTo @model, 'change', =>
      if @rendering
        @renderData()


  render: =>
    super
    @$el.empty()
    @$el.html @template()
    @renderData()
    @


  renderData: =>
    @$('.title').text @model.title()
    @$('.description').text @model.description()
    @$('.thumbnail-view img').attr 'src', @model.thumbnail()
    @
