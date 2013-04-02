goog.provide 'acorn.player.EditSummaryView'
goog.require 'acorn.player.SummaryView'
goog.require 'acorn.player.EditImageView'
goog.require 'acorn.shells.ImageLinkShell'


class acorn.player.EditSummaryView extends acorn.player.SummaryView


  className: @classNameExtend 'edit-summary-view'


  template: _.template '''
    <div class="thumbnail-view span3">
      <img class="img-rounded" src="" />
    </div>
    <div class="span9">
      <input type="text" placeholder="title" class="title">
      <textarea placeholder="description" class="description"></textarea>
      <div class="buttons"></div>
    </div>
    '''

  events: => _.extend super,
    'keyup input': @_markupDefaults
    'keyup textarea': @_markupDefaults
    'blur input': @saveData
    'blur textarea': @saveData
    'click .thumbnail-view': =>
      @popoverView.toggle()
      @_markupDefaults()


  initialize: =>
    super
    @setModel @model # bind listener

    imageModel = new ImageLinkShell.Model link: @model.thumbnail()
    @editImageView = new acorn.player.EditImageView
      eventhub: @eventhub
      model: imageModel

    @popoverView = new athena.lib.PopoverView
      eventhub: @eventhub
      content: @editImageView
      trigger: 'manual'
      placementOffset: top: 70

    @listenTo @popoverView, 'PopoverView:PopoverDidShow', =>
      @editImageView.$('#link').select()

    @listenTo @editImageView, 'EditImage:Cancel', =>
      @editImageView.model.link @model.thumbnail()
      @popoverView.hide()

    @listenTo @editImageView, 'EditImage:Save', =>
      @model.thumbnail @editImageView.model.link()
      @popoverView.hide()


  setModel: (model) =>
    oldModel = @model
    super

    @_transferNonDefaultValues @model, oldModel


  onModelChange: =>
    super
    @editImageView?.model.link @model.thumbnail()


  render: =>
    super
    @popoverView.options.popover = @$('.thumbnail-view')
    @popoverView.render()
    @


  renderData: =>
    @$('.title').val @model.title()
    @$('.description').val @model.description()
    @$('.thumbnail-view img').attr 'src', @model.thumbnail()
    @_markupDefaults()
    @


  saveData: =>
    @model.title @value 'title' if @value 'title'
    @model.description @value 'description' if @value 'description'
    @renderData()
    @


  value: (field) =>
    @$(".#{field}")?.val()?.trim()


  _markupDefaults: =>
    fields =
      title: @$ '.title'
      description: @$ '.description'
      thumbnail: @$ '.popover-view #link'

    for attribute, field of fields
      if field.val()?.trim() == @model.defaultAttributes()[attribute]
        field.addClass 'default'
      else
        field.removeClass 'default'


  _transferNonDefaultValues: (newModel, oldModel) =>
    unless newModel and oldModel
      return

    attributes = ['title', 'description', 'thumbnail']

    # transfer attributes that have been changed from their defaults
    for attr in attributes
      unless oldModel[attr]() == oldModel.defaultAttributes()[attr]
        newModel[attr] oldModel[attr]()
