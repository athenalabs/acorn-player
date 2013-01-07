goog.provide 'acorn.player.ShellEditorView'

goog.require 'acorn.player.ShellOptionsView'
goog.require 'acorn.player.RemixerView'
goog.require 'acorn.shells.EmptyShell'



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
EmptyShell = acorn.shells.EmptyShell
CollectionShell = acorn.shells.CollectionShell

# View to edit a shell. Renders shells' RemixViews.
class acorn.player.ShellEditorView extends athena.lib.View


  className: @classNameExtend 'shell-editor-view'


  template: _.template '''
    <div class="shell-options-view row-fluid"></div>
    <div class="remix-views"></div>
    '''


  defaultShell: EmptyShell


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
      @model.shells().push new @defaultShell.Model

    @shellOptionsView = new acorn.player.ShellOptionsView
      eventhub: @eventhub
      model: @model

    @remixerViews = @model.shells().map @remixerForShell

    @on 'ShellEditor:ShellsUpdated', @renderUpdates


  render: =>
    super
    @$el.empty()

    @$el.html @template()
    @renderOptionsView()
    _.each @remixerViews, @renderRemixerView
    @renderUpdates()
    @


  renderOptionsView: =>
    @shellOptionsView.setElement @$ '.shell-options-view'
    @shellOptionsView.render()
    @


  renderRemixerView: (remixerView, index) =>
    remixerView.render()
    if index?
      @$('.remix-views').insertAt index, remixerView.el
    else
      @$('.remix-views').append remixerView.el
    @


  renderUpdates: =>
    shellCount = @model.shells().length
    emptyCount = _.size @model.shells().filter (shell) =>
      shell.module is @defaultShell

    # hide the options view if there is only one shell
    if @rendering
      display = if (shellCount - emptyCount) > 1 then 'block' else 'none'
      @$('.shell-options-view').css 'display', display

    # if there are no shells, add an empty one
    if emptyCount is 0
      @addShell new @defaultShell.Model, shellCount


  # retrieves the finalized shell. @model should not be used directly.
  shell: =>
    shell = @model.clone()

    # retrieve shells from views. seem to be out of sync. Bug?
    shells = _.map @remixerViews, (view) => view.model

    # clear out any empty shells
    shell.shells().reset _.filter shells, (shell) =>
      not @shellIsEmpty shell

    # unwrap from collection if there is only one shell
    if shell.shells().length is 1
      shell = shell.shells().models[0]

    shell


  addShell: (shell, index) =>
    index ?= @model.shells().length - 1 # -1 = before @defaultShell
    @model.shells().add shell, at: index

    remixerView = @remixerForShell shell
    @remixerViews.splice(index, 0, remixerView)

    if @rendering
      @renderRemixerView remixerView, index
      @trigger 'ShellEditor:ShellsUpdated'

    @


  removeShell: (shell) =>
    index = @model.shells().indexOf shell
    @model.shells().remove shell

    [view] = @remixerViews.splice(index, 1)
    view.destroy()
    @trigger 'ShellEditor:ShellsUpdated'
    @


  # whether the shell is considered empty (placeholders)
  shellIsEmpty: (shell) =>
    shell &&
    (shell.constructor is Shell.Model or
     shell.constructor is EmptyShell.Model or
     shell.constructor is @defaultShell.Model)


  # initializes a RemixerView for given shell
  remixerForShell: (shell) =>
    view = new acorn.player.RemixerView
      eventhub: @eventhub
      model: shell

    view.on 'Remixer:Duplicate', (remixer) =>
      index = @model.shells().indexOf(remixer.model)
      @addShell remixer.model.clone(), index + 1

    view.on 'Remixer:Delete', (remixer) =>
      @removeShell remixer.model

    view.on 'Remixer:SwapShell', (remixer, oldShell, newShell) =>
      @swapSubShell oldShell, newShell

    view


  # swaps a subshell with given shell
  swapSubShell: (oldShell, newShell) =>
    index = @model.shells().indexOf(oldShell)
    @model.shells().remove oldShell
    @model.shells().add newShell, {at: index}

    unless @remixerViews[index].model is newShell
      @remixerViews[index].destroy()
      @remixerViews[index] = @remixerForShell newShell

    @trigger 'ShellEditor:ShellsUpdated'
    @


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
