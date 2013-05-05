goog.provide 'acorn.player.ShellEditorView'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.player.RemixerView'


Shell = acorn.shells.Shell
EmptyShell = acorn.shells.EmptyShell
RemixerView = acorn.player.RemixerView

# View to edit a shell. Renders shells' RemixViews.
class acorn.player.ShellEditorView extends athena.lib.View


  className: @classNameExtend 'shell-editor-view'


  defaults: => _.extend super,
    minimize: false


  template: _.template '''
    <div class="remix-views"></div>
    '''


  defaultShell: EmptyShell


  initialize: =>
    super

    @_initializeModel()
    @_initializeRemixerViews()

    if @options.minimize
      @minimize()

    @on 'ShellEditor:ShellsUpdated', @_renderUpdates


  _initializeModel: =>
    # ensure we have a proper Shell
    unless @model instanceof Shell.Model
      @model = new @defaultShell.Model


  _initializeRemixerViews: =>
    @remixerViews = [@_initializeRemixerForShell @model]


  # initializes a RemixerView for given shell
  _initializeRemixerForShell: (shell) =>
    view = new RemixerView
      eventhub: @eventhub
      model: shell
      toolbarButtons: @_remixerToolbarButtons()

    view.on 'Remixer:SwapShell', @_onRemixerSwapShell
    view.on 'Remixer:LinkChanged', @_onRemixerLinkChanged

    view


  _remixerToolbarButtons: =>
    [
      {id:'Clear', icon: 'icon-undo', tooltip: 'Clear'}
    ]


  _minimizedRemixerToolbarButtons: =>
    []


  render: =>
    super

    @$el.empty()
    @$el.html @template()

    @_renderHeader()
    @_renderRemixerViews()
    @_renderFooter()

    @_renderUpdates()
    @


  _renderHeader: =>


  _renderRemixerViews: =>
    _.each @remixerViews, @_renderRemixerView


  _renderRemixerView: (remixerView, index) =>
    index ?= @model.shells().indexOf(remixerView.model)

    remixerView.render()
    remixerView.$el.append $('<hr>')
    if index?
      @$('.remix-views').insertAt index, remixerView.el
    else
      @$('.remix-views').append remixerView.el

    @


  _renderFooter: =>


  _renderUpdates: =>
    if @rendering
      # update remixerView headers and mark any stub remixers
      _.each @remixerViews, (remixer) =>
        @_renderRemixerViewHeading remixer
        if @_shellIsStub remixer.model
          remixer.$el.addClass 'stub-remixer'
        else
          remixer.$el.removeClass 'stub-remixer'

    unless @_lastThumbnail is @model.thumbnail()
      @_onThumbnailChange()

    @


  _renderRemixerViewHeading: (remixerView, index) =>
    @_renderSectionHeading remixerView
    @


  _renderSectionHeading: (view, prefix) =>
    view.$('.editor-section').remove()

    if @_shellIsStub view.model
      text = 'add a media item by entering a link:'
    else
      text = view.model.module.title

    if prefix
      text = prefix + ': ' + text
    view.$el.prepend $('<h3>').addClass('editor-section').text(text)


  _setRemixerToolbarButtons: (buttons) =>
    unless buttons?
      return

    for remixer in @remixerViews
      remixer.setToolbarButtons buttons


  minimize: =>
    @$el.addClass 'minimized'
    @minimized = true
    @_setRemixerToolbarButtons @_minimizedRemixerToolbarButtons()


  expand: =>
    @$el.removeClass 'minimized'
    @minimized = false
    @_setRemixerToolbarButtons @_remixerToolbarButtons()


  # retrieves the finalized shell. @model should not be used directly.
  shell: =>
    @model.clone()


  # whether the model should be considered empty
  isEmpty: =>
    @_shellIsStub @model


  # whether this is the stub shell (last shell and empty)
  _shellIsStub: (shell) =>
    shell?.constructor is @defaultShell.Model


  _onThumbnailChange: =>
    # notify of any thumbnail changes
    @_lastThumbnail = @model.thumbnail()
    @trigger 'ShellEditor:Thumbnail:Change', @_lastThumbnail
    @eventhub.trigger 'ShellEditor:Thumbnail:Change', @_lastThumbnail


  _onRemixerSwapShell: (remixer, oldShell, newShell) =>
    @model = newShell

    unless @remixerViews[0].model is @model
      @remixerViews[0].destroy()
      @remixerViews[0] = @_initializeRemixerForShell @model

    @trigger 'ShellEditor:ShellsUpdated'


  _onRemixerLinkChanged: (remixer, newlink) =>
    @trigger 'ShellEditor:ShellsUpdated'
