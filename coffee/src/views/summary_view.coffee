
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
    @setModel @model # bind listener


  setModel: (model) =>
    @stopListening @model if @model
    @model = model

    @listenTo @model, 'change', @onModelChange
    @onModelChange()


  onModelChange: =>
    if @rendering
      @renderData()


  render: =>
    super
    @$el.empty()
    @$el.removeClass('editable')
    @$el.html @template()
    @renderData()
    @


  renderData: =>
    icon = $('<i>').addClass @model.module.icon
    icon.tooltip title: @model.module.description, placement: 'right'

    # must be split, as `.text` will return '', not the selector if
    # @model.title() returns falsy. (will be taken as a getter, not setter)
    title = @$('.title').first()
    title.text(@model.title())
    title.append(icon)

    @$('.description').first().text @model.description()
    @$('.thumbnail-view img').first().attr 'src', @model.thumbnail()
    @
