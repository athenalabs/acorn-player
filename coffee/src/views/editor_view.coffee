goog.provide 'acorn.player.EditorView'

goog.require 'acorn.player.AcornOptionsView'
goog.require 'acorn.player.ShellOptionsView'

# acorn player EditorView:
# ------------------------------------------------
# |  ----------                                  |
# |  |        |    acornid:                      |
# |  |        |    [ title                    ]  |
# |  ----------                                  |
# |                                              |
# |  ------------------------------------------  |
# |  | > |  Type of Media                 | v |  |
# |  ------------------------------------------  |
# |                                              |
# |  ------------------------------------------  |
# |  | > |  http://link.to.media          | v |  |
# |  ------------------------------------------  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  ------------------------------------------  |
# |                                              |
# |                         [ Cancel ] [ Save ]  |
# ------------------------------------------------


# View to edit an acorn. Renders shells' EditorViews.
class acorn.player.EditorView extends athena.lib.View

  className: @::className + ' editor-view span8'

  events: => _.extend super,
    'click #editor-cancel-btn': => @eventhub.trigger 'Editor:Cancel', @
    'click #editor-save-btn': => @save()

  initialize: =>
    super

    @acornOptionsView = new acorn.player.AcornOptionsView
      model: @model.acornModel
      eventhub: @eventhub

    @shellOptionsView = new acorn.player.ShellOptionsView
      model: @model.shellModel
      eventhub: @eventhub

    cancel = text: 'Cancel', id: 'editor-cancel-btn'
    save = text: 'Save', id: 'editor-save-btn', className: 'btn-success'

    @toolbarView = new athena.lib.ToolbarView
      buttons: [cancel, save]
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    @$el.append @acornOptionsView.render().el
    @$el.append @shellOptionsView.render().el
    @$el.append @toolbarView.render().el

    @

  save: =>
    # TODO add validation first

    # update acornModel with edited shellModel data
    @model.acornModel.shellData @model.shellModel.attributes

    @$('#editor-save-btn').attr 'disabled', 'disabled'
    @$('#editor-save-btn').text 'Saving...'

    @model.acornModel.save {},
      success: =>
        @$('#editor-save-btn').text 'Saved!'
        @eventhub.trigger 'Editor:Saved', @

      error: =>
        @$('#editor-save-btn').text 'Error Saving. Click to try again.'
        @$('#editor-save-btn').removeAttr 'disabled'

    @
