`import "collection_shell_editor_view"`


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


  defaults: => _.extend super,
    ShellEditorView: acorn.player.CollectionShellEditorView
    minimize: false


  events: => _.extend super,
    'click #editor-cancel-btn': => @eventhub.trigger 'Editor:Cancel', @
    'click #editor-save-btn': => @save()


  initialize: =>
    super

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'

    @shellEditorView = new @options.ShellEditorView
      model: acorn.shellWithAcorn @model
      eventhub: @eventhub
      minimize: @options.minimize

    if @options.minimize
      @minimize()

    btns = []
    unless @model.isNew()
      btns.push {text: 'Cancel', id: 'editor-cancel-btn'}
    btns.push {text: 'Save', id: 'editor-save-btn', className: 'btn-success'}

    @toolbarView = new athena.lib.ToolbarView
      buttons: btns
      eventhub: @eventhub

    @listenTo @shellEditorView, 'ShellEditor:ShellsUpdated', @_updateSaveButton
    @listenTo @shellEditorView, 'ShellEditor:Minimize', @minimize
    @listenTo @shellEditorView, 'ShellEditor:Expand', @expand


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

    @$('#editor-save-btn').first().attr 'disabled', 'disabled'
    @$('#editor-save-btn').first().text 'Saving...'

    @model.save {},
      success: =>
        @$('#editor-save-btn').first().text 'Saved!'
        @eventhub.trigger 'Editor:Saved', @

      error: =>
        @$('#editor-save-btn').first().text 'Error Saving. Click to try again.'
        @$('#editor-save-btn').first().removeAttr 'disabled'

    @


  minimize: =>
    unless @minimized
      @$el.addClass 'minimized'
      @minimized = true
      @shellEditorView.minimize()
      @trigger 'Editor:Minimize'


  expand: =>
    if @minimized
      @$el.removeClass 'minimized'
      @minimized = false
      @shellEditorView.expand()
      @trigger 'Editor:Expand'


  canBeSaved: =>
    # TODO add more validation?

    if @model.isNew() and @shellEditorView.isEmpty()
      false
    else
      true


  _updateSaveButton: =>
    if @canBeSaved()
      @$('#editor-save-btn').first().removeAttr 'disabled'
    else
      @$('#editor-save-btn').first().attr 'disabled', 'disabled'
