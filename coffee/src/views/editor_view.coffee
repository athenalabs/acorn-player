goog.provide 'acorn.player.EditorView'
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

    @shellEditorView = new acorn.player.ShellEditorView
      model: acorn.shellWithAcorn @model
      eventhub: @eventhub

    btns = []
    unless @model.isNew()
      btns.push {text: 'Cancel', id: 'editor-cancel-btn'}
    btns.push {text: 'Save', id: 'editor-save-btn', className: 'btn-success'}

    @toolbarView = new athena.lib.ToolbarView
      buttons: btns
      eventhub: @eventhub

    @listenTo @shellEditorView, 'ShellEditor:ShellsUpdated', @_updateSaveButton


  render: =>
    super
    @$el.empty()

    text = 'new media'
    text = 'editing ' + @model.acornid() unless @model.isNew()
    @$el.append $('<h2>').addClass('editor-section').text(text)

    @$el.append @shellEditorView.render().el
    @$el.append @toolbarView.render().el

    @_updateSaveButton()

    @


  save: =>
    unless @canBeSaved()
      return

    # update acornModel with edited shellModel data
    @model.shellData @shellEditorView.shell().attributes

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


  canBeSaved: =>
    # TODO add more validation?

    if @model.isNew() and @shellEditorView.isEmpty()
      false
    else
      true


  _updateSaveButton: =>
    if @canBeSaved()
      @$('#editor-save-btn').removeAttr 'disabled'
    else
      @$('#editor-save-btn').attr 'disabled', 'disabled'
