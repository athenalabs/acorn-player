goog.provide 'acorn.player.ShellEditorView'

goog.require 'acorn.player.ShellOptionsView'
goog.require 'acorn.player.RemixerView'

# acorn player ShellEditorView:
#   ------------------------------------------
#   | > |  Type of Media                 | v |
#   ------------------------------------------
#
#   ------------------------------------------
#   | > |  http://link.to.media          | v |
#   ------------------------------------------
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   ------------------------------------------


# Keep remixerView set
# use that to compute current shells
# let all events that add or remove shells modify this set
# figure out whether shell must change based on final state

Shell = acorn.shells.Shell
CollectionShell = acorn.shells.CollectionShell

# View to edit a shell. Renders shells' RemixViews.
class acorn.player.ShellEditorView extends athena.lib.View

  className: @classNameExtend 'shell-editor-view'

  template: _.template '''
    <div class="shell-options-view"></div>
    <div class="remix-views"></div>
    '''

  initialize: =>
    super

    # ensure we have a proper Shell
    if @model and not @model instanceof Shell.Model
      TypeError @model, 'Shell.Model'

    # ensure we have an outermost CollectionShell
    unless @model instanceof CollectionShell.Model
      model = @model
      @model = new CollectionShell.Model
      @model.shells().push model if model

    # add an empty shell at the end, ready for a new link
    unless @shellIsEmpty @model.shells().last()
      @model.shells().push new EmptyShell.Model

    @shellOptionsView = new acorn.player.ShellOptionsView
      eventhub: @eventhub
      model: @model

    @remixerViews = @model.shells().map @remixerForShell


  render: =>
    super
    @$el.empty()

    @$el.html @template()
    @renderOptionsView()
    _.each @remixerViews, @renderRemixerView

    @

  renderOptionsView: =>
    @shellOptionsView.setElement @$ '.shell-options-view'
    @shellOptionsView.render()

    # hide the options view if there is only one shell
    if @model.shells().length > 1
      @$('.shell-options-view').css 'display', 'none'
    @

  renderRemixerView: (remixerView, index) =>
    remixerView.render()
    if index?
      @$('.remix-views').insertAt index, remixerView.el
    else
      @$('.remix-views').append remixerView.el
    @


  # retrieves the finalized shell. @model should not be used directly.
  shell: =>
    shell = @model.clone()

    # clear out any empty shells
    shell.shells().reset shell.shells().filter (shell) =>
      not @shellIsEmpty shell

    # unwrap from collection if there is only one shell
    if shell.shells().length is 1
      shell = shell.shells().models[0]

    shell

  addShell: (shell, index) =>
    index ?= @model.shells().length - 1 # -1 = before EmptyShell
    @model.shells().add shell, at: index

    remixerView = @remixerForShell shell
    @remixerViews.splice(index, 0, remixerView)

    if @rendering
      @renderRemixerView remixerView, index
    @

  removeShell: (shell) =>
    index = @model.shells().index shell
    @model.shells().remove shell

    [view] = @remixerViews.splice(index, 1)
    view.destroy()
    @

  # whether the shell is considered empty (placeholders)
  shellIsEmpty: (shell) =>
    shell &&
    (shell.constructor is Shell.Model or
     shell.constructor is EmptyShell.Model)

  # initializes a RemixerView for given shell
  remixerForShell: (shell) =>
    new acorn.player.RemixerView
      eventhub: @eventhub
      model: shell

  # swaps the main shell with given shell
  swapTopLevelShell: (shell) =>
    unless shell instanceof CollectionShell
      TypeError shell, 'CollectionShell'

    @shellOptionsView?.destroy()

    _.map @model.shells(), shell.addShell
    @model = shell

    @shellOptionsView = new acorn.player.ShellOptionsView
      eventhub: @eventhub
      model: @model

    if @rendering
      @renderOptionsView()
    @
