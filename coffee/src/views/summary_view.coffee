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


  editableTemplate: _.template '''
    <div class="thumbnail-view span3">
      <img class="img-rounded" src="" />
    </div>
    <div class="span9">
      <input type="text" class="title">
      <textarea class="description"></textarea>
      <div class="buttons"></div>
    </div>
    '''

  events: => _.extend super,
    'keyup input': @saveData
    'keyup textarea': @saveData


  defaults: => _.extend super,

    # whether this summary view is editable or not.
    editable: false


  initialize: =>
    super
    @setModel @model # bind listener


  setModel: (model) =>
    @model = model

    @listenTo @model, 'change', =>
      titleChanged = @model.title() isnt @value 'title'
      descChanged = @model.description() isnt @value 'description'

      if @rendering and (titleChanged or descChanged)
        @renderData()

    if @rendering
      @renderData()


  render: =>
    super
    @$el.empty()
    if @options.editable
      @$el.addClass('editable')
      @$el.html @editableTemplate()
    else
      @$el.removeClass('editable')
      @$el.html @template()
    @renderData()
    @


  renderData: =>
    if @options.editable
      @$('.title').val @model.title()
      @$('.description').val @model.description()
    else
      @$('.title').text @model.title()
      @$('.description').text @model.description()
    @$('.thumbnail-view img').attr 'src', @model.thumbnail()
    @


  saveData: =>
    @model.title @value 'title'
    @model.description @value 'description'
    @


  value: (field) =>
    @$(".#{field}")?.val()?.trim()
