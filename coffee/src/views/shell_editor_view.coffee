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

    # add a default shell at the end, ready for a new link
    unless @_shellIsStub @model.shells().last()
      @model.shells().push new @defaultShell.Model

    @initializeShellOptionsView()

    @remixerViews = @model.shells().map @remixerForShell

    @on 'ShellEditor:ShellsUpdated', @renderUpdates


  # initializes the ShellOptionsView
  initializeShellOptionsView: =>

    @shellOptionsView?.destroy()
    @shellOptionsView = new acorn.player.ShellOptionsView
      eventhub: @eventhub
      model: @model

    @shellOptionsView.on 'ShellOptions:SwapShell', (shellid) =>
      module = acorn.shellModuleWithId shellid
      @swapTopLevelShell new module.Model


  render: =>
    super
    @$el.empty()

    @$el.html @template()
    @renderOptionsView()
    _.each @remixerViews, @renderRemixerView
    @renderUpdates()
    @


  renderOptionsView: =>
    @$el.prepend @shellOptionsView.render().el
    @renderSectionHeading @shellOptionsView, 'Collection'
    @


  renderRemixerView: (remixerView, index) =>
    index ?= @model.shells().indexOf(remixerView.model)

    remixerView.render()
    remixerView.$el.append $('<hr>')
    if index?
      @$('.remix-views').insertAt index, remixerView.el
    else
      @$('.remix-views').append remixerView.el

    @

  renderRemixerViewHeading: (remixerView, index) =>
    index ?= @model.shells().indexOf(remixerView.model)

    unless @model.shells().length < 3 or @_shellIsStub remixerView.model
      prefix = "Item #{index + 1}"

    @renderSectionHeading remixerView, (prefix ? '')
    @


  renderSectionHeading: (view, prefix='') =>
    view.$('.editor-section').remove()

    if @_shellIsStub view.model
      text = 'add a media item by entering a link:'
    else
      text = view.model.module.title

    if prefix
      text = prefix + ': ' + text
    view.$el.prepend $('<h3>').addClass('editor-section').text(text)


  renderUpdates: =>
    # ensure there is a stub shell
    unless @_shellIsStub @model.shells().last()
      @addShell new @defaultShell.Model, @model.shells().length

    if @rendering
      # hide the options view if there is only one shell
      if @_lastNonDefaultShellIndex() > 0
        @$('.shell-options-view').removeClass 'hidden'
      else
        @$('.shell-options-view').addClass 'hidden'

      # update remixView headers
      _.each @remixerViews, @renderRemixerViewHeading

    # notify of any thumbnail changes
    unless @lastThumbnail is @model.thumbnail()
      @lastThumbnail = @model.thumbnail()
      @trigger 'ShellEditor:Thumbnail:Change', @lastThumbnail
      @eventhub.trigger 'ShellEditor:Thumbnail:Change', @lastThumbnail
      @shellOptionsView.model.trigger 'change'

    @


  # retrieves the finalized shell. @model should not be used directly.
  shell: =>
    # retrieve shells from views, leaving out any trailing default shells
    lastIndex = @_lastNonDefaultShellIndex()
    shells = if lastIndex < 0 then [] else
      for i in [0..@_lastNonDefaultShellIndex()]
        @remixerViews[i].model

    shell = @model.clone()
    shell.shells().reset shells

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


  # whether this is the stub shell (last shell and empty)
  _shellIsStub: (shell) =>
    shell?.constructor is @defaultShell.Model &&
    shell is @model.shells().last()


  # the index of the last shell that is not a default shell
  _lastNonDefaultShellIndex: =>
    shells = @model.shells()
    index = shells.length
    while index--
      unless shells.at(index)?.constructor is @defaultShell.Model
        return index
    -1


  # initializes a RemixerView for given shell
  remixerForShell: (shell) =>
    view = new acorn.player.RemixerView
      eventhub: @eventhub
      model: shell

    view.on 'Remixer:Toolbar:Click:Duplicate', (remixer) =>
      # duplicate shell
      index = @model.shells().indexOf(remixer.model)
      @addShell remixer.model.clone(), index + 1

    view.on 'Remixer:Toolbar:Click:Delete', (remixer) =>
      # delete remixer unless it is the stub
      unless @_shellIsStub remixer.model
        @removeShell remixer.model

    view.on 'Remixer:SwapShell', (remixer, oldShell, newShell) =>
      @swapSubShell oldShell, newShell

    view.on 'Remixer:LinkChanged', (remixer, newlink) =>
      @trigger 'ShellEditor:ShellsUpdated'

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
    unless shell instanceof CollectionShell.Model
      TypeError shell, 'CollectionShell.Model'

    shell.shells().add @model.shells().models
    @model = shell

    @initializeShellOptionsView()
    if @rendering
      @renderOptionsView()
      @trigger 'ShellEditor:ShellsUpdated'
    @
