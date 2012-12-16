goog.provide 'acorn.player.EditorView'

goog.require 'acorn.player.AcornOptionsView'
goog.require 'acorn.player.ShellEditorView'

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

  className: @classNameExtend 'editor-view'

  events: => _.extend super,
    'click #editor-cancel-btn': => @eventhub.trigger 'Editor:Cancel', @
    'click #editor-save-btn': => @save()

  initialize: =>
    super

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'

    @acornOptionsView = new acorn.player.AcornOptionsView
      model: @model
      eventhub: @eventhub

    @shellEditorView = new acorn.player.ShellEditorView
      model: acorn.shellWithAcorn @model
      eventhub: @eventhub

    @toolbarView = new athena.lib.ToolbarView
      buttons: [
        {text: 'Cancel', id: 'editor-cancel-btn'},
        {text: 'Save', id: 'editor-save-btn', className: 'btn-success'},
      ]
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    @$el.append @acornOptionsView.render().el
    @$el.append @shellEditorView.render().el
    @$el.append @toolbarView.render().el

    @

  save: =>
    # TODO add validation first

    # update acornModel with edited shellModel data
    @model.shellData @shellEditorView.model.attributes

    @$('#editor-save-btn').attr 'disabled', 'disabled'
    @$('#editor-save-btn').text 'Saving...'

    @model.save {},
      success: =>
        @$('#editor-save-btn').text 'Saved!'
        @eventhub.trigger 'Editor:Saved', @

      error: =>
        @$('#editor-save-btn').text 'Error Saving. Click to try again.'
        @$('#editor-save-btn').removeAttr 'disabled'

    @
