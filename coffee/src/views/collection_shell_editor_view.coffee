goog.provide 'acorn.player.CollectionShellEditorView'

goog.require 'acorn.shells.CollectionShell'
goog.require 'acorn.player.ShellOptionsView'
goog.require 'acorn.player.ShellEditorView'


CollectionShell = acorn.shells.CollectionShell
ShellOptionsView = acorn.player.ShellOptionsView
ShellEditorView = acorn.player.ShellEditorView

# View to edit a shell. Renders shells' RemixViews.
class acorn.player.CollectionShellEditorView extends ShellEditorView


  className: @classNameExtend 'collection-shell-editor-view'


  initialize: =>
    super
    @_initializeShellOptionsView()


  _initializeModel: =>
    super

    # ensure we have an outermost CollectionShell
    unless @model instanceof CollectionShell.Model
      model = @model
      @model = new CollectionShell.Model
      @model.shells().push model

    # add a default shell at the end, ready for a new link
    unless @_shellIsStub @model.shells().last()
      @model.shells().push new @defaultShell.Model


  _initializeRemixerViews: =>
    @remixerViews = @model.shells().map @_initializeRemixerForShell


  _initializeRemixerForShell: (shell) =>
    view = super

    view.on 'Remixer:Toolbar:Click:Duplicate', @_onRemixerClickDuplicate
    view.on 'Remixer:Toolbar:Click:Delete', @_onRemixerClickDelete

    view


  _remixerToolbarButtons: =>
    [
      {id:'Clear', icon: 'icon-undo', tooltip: 'Clear'}
      {id:'Duplicate', icon: 'icon-copy', tooltip: 'Duplicate'}
      {id:'Delete', icon: 'icon-remove', tooltip: 'Delete'}
    ]


  _initializeShellOptionsView: =>

    @shellOptionsView?.destroy()
    @shellOptionsView = new ShellOptionsView
      eventhub: @eventhub
      model: @model

    @shellOptionsView.on 'ShellOptions:SwapShell', (shellid) =>
      module = acorn.shellModuleWithId shellid
      @_swapTopLevelShell new module.Model


  _renderHeader: =>
    @$el.prepend @shellOptionsView.render().el
    @_renderSectionHeading @shellOptionsView, 'Collection'
    @


  _renderUpdates: =>
    # ensure there is a stub shell before rendering updates
    unless @_shellIsStub @model.shells().last()
      @addShell new @defaultShell.Model, @model.shells().length

    super

    if @rendering
      # hide the options view if there is only one shell
      if @_lastNonDefaultShellIndex() > 0
        @$('.shell-options-view').removeClass 'hidden'
      else
        @$('.shell-options-view').addClass 'hidden'

    @


  _renderRemixerViewHeading: (remixerView, index) =>
    index ?= @model.shells().indexOf(remixerView.model)

    unless @model.shells().length < 3 or @_shellIsStub remixerView.model
      prefix = "Item #{index + 1}"

    @_renderSectionHeading remixerView, (prefix ? '')
    @


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


  isEmpty: =>
    shellData = @shell().attributes
    isEmpty = shellData.shellid == 'acorn.CollectionShell' and
        shellData.shells.length == 0


  _shellIsStub: (shell) =>
    shell?.constructor is @defaultShell.Model &&
    shell is @model.shells().last()


  addShell: (shell, index) =>
    index ?= @model.shells().length - 1 # -1 = before @defaultShell
    @model.shells().add shell, at: index

    remixerView = @_initializeRemixerForShell shell
    @remixerViews.splice(index, 0, remixerView)

    if @rendering
      @_renderRemixerView remixerView, index
      @trigger 'ShellEditor:ShellsUpdated'

    @


  removeShell: (shell) =>
    index = @model.shells().indexOf shell
    @model.shells().remove shell

    [view] = @remixerViews.splice(index, 1)
    view.destroy()
    @trigger 'ShellEditor:ShellsUpdated'
    @


  # the index of the last shell that is not a default shell
  _lastNonDefaultShellIndex: =>
    shells = @model.shells()
    index = shells.length
    while index--
      unless shells.at(index)?.constructor is @defaultShell.Model
        return index
    -1


  # swaps a subshell with given shell
  _swapSubShell: (oldShell, newShell) =>
    index = @model.shells().indexOf oldShell
    @model.shells().remove oldShell
    @model.shells().add newShell, {at: index}

    unless @remixerViews[index].model is newShell
      @remixerViews[index].destroy()
      @remixerViews[index] = @_initializeRemixerForShell newShell

    @trigger 'ShellEditor:ShellsUpdated'
    @


  # swaps the main shell with given shell
  _swapTopLevelShell: (shell) =>
    unless shell instanceof CollectionShell.Model
      TypeError shell, 'CollectionShell.Model'

    shell.shells().add @model.shells().models
    @model = shell

    @_initializeShellOptionsView()
    if @rendering
      @_renderHeader()
      @trigger 'ShellEditor:ShellsUpdated'
    @


  _onThumbnailChange: =>
    super
    @shellOptionsView.model.trigger 'change'


  _onRemixerSwapShell: (remixer, oldShell, newShell) =>
    @_swapSubShell oldShell, newShell


  _onRemixerClickDuplicate: (remixer) =>
    # duplicate shell
    index = @model.shells().indexOf(remixer.model)
    @addShell remixer.model.clone(), index + 1


  _onRemixerClickDelete: (remixer) =>
    # delete remixer unless it is the stub
    unless @_shellIsStub remixer.model
        @removeShell remixer.model
