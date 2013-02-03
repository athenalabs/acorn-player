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
      <input type="text" class="title">
      <textarea class="description"></textarea>
      <div class="buttons"></div>
    </div>
    '''

  events: => _.extend super,
    'keyup input': @saveData
    'keyup textarea': @saveData


  initialize: =>
    super
    @setModel @model # bind listener


  render: =>
    super
    @


  renderData: =>
    @$('.title').val @model.title()
    @$('.description').val @model.description()
    @$('.thumbnail-view img').attr 'src', @model.thumbnail()
    @


  saveData: =>
    @model.title @value 'title'
    @model.description @value 'description'
    @


  value: (field) =>
    @$(".#{field}")?.val()?.trim()
