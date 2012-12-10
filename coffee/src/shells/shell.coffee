goog.provide 'acorn.shells'
goog.provide 'acorn.shells.Shell'

goog.require 'acorn.Model'
goog.require 'acorn.util'
goog.require 'acorn.errors'
goog.require 'athena.lib.View'


class acorn.shells.ShellModel extends Backbone.Model

  constructor: (options) ->
    @options = _.extend {}, @defaults ? {}, options
    @data = JSON.parse JSON.stringify @options.data
    @data.shell ?= @shellid
    acorn.util.assert @data.shell == @shellid,
                      'Shell data has incorrect type.'
    @initialize()

  defaults: =>
    autoplay: false # whether playable media automatically starts playing.

  # The unique `shell` name of an acorn Shell.
  # The convention is to namespace by vendor. e.g. `acorn.Document`.
  shellid: 'acorn.Shell',

  # The shell-specific control components to use.
  controls: [],

  # Returns a simple title of the shell
  # Override it with your own shell-specific code.
  title: => NotImplementedError 'Shell::title'

  # Returns a simple description of the shell
  # Override it with your own shell-specific code.
  description: => ''

  # Returns a remoteResource object whose data() function
  # Caches and returns this Shell's thumbnail link. Stub implementation --
  # Intended to be overriden by derived classes.
  thumbnailLink: => NotImplementedError 'Shell::thumbnailLink'

  clone: => new @()

  # disable Backbone's sync functionality
  sync: => NotSupportedError 'Backbone::sync'


  # --factory constructors --

  @withAcorn: (acornModel) => @withData acornModel.shellData()

  @withData: (data) =>
    shellClass = _(acorn.shells).find (shell) ->
      shell.shellid == data.shell

    unless shellClass?
      UndefinedShellError data.shell

    new shellClass data: data



# Shell.ShellView -- top level view for acorn shells
# --------------------------------------------------

class acorn.shells.ShellView extends athena.lib.View

  initialize: =>
    super()
    @shell = @options.shell
    @

    acorn.util.assert @shell, 'No shell provided to ShellView'



# acorn Player:
# ------------------------------------------------------------------
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                       Content Shell                            |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# |                                                                |
# ------------------------------------------------------------------
# |                       Player Controls                          |
# ------------------------------------------------------------------

class acorn.shells.ContentView extends acorn.shells.ShellView

  className: 'acorn-shell'

  initialize: =>
    super()
    @eventhub.on 'playback:play', @onPlaybackPlay
    @eventhub.on 'playback:stop', @onPlaybackStop
    @

  remove: =>
    @eventhub.off 'playback:play', @onPlaybackPlay
    @eventhub.off 'playback:stop', @onPlaybackStop
    super()

  setControlsView: (controlsView) =>
    @controlsView = controlsView
    @controlsView.setControls _.clone(@shell.controls)
    @onControlSet()

  onControlsSet: =>
  onPlaybackPlay: =>
  onPlaybackStop: =>



# Shell.SummaryView -- uniform view to summarize a shell.
# -------------------------------------------------------
#
# +-----------+
# |           |   Title of This Wonderful Shell
# |   thumb   |   A short description of this particular shell.
# |           |   [ action ] [ action ] ...
# +-----------+
#
# The actions are buttons that vary depending on the use-case of the
# SummaryView. The title and description are now overridable functions
# in Shell.

class acorn.shells.SummaryView extends acorn.shells.ShellView

  className: 'acorn-shell-summary'

  template: _.template '''
    <img id="thumbnail" />
    <div class="thumbnailside">
      <div id="title"></div>
      <div id="description"></div>
      <div id="buttons"></div>
    </div>
    '''

  render: =>
    @$el.empty()
    @$el.html @template()

    @$el.find('#title').text @shell.title()
    @$el.find('#description').text @shell.description()
    @$el.find('#thumbnail').attr 'src', @shell.thumbnailLink()



# Shell.EditView -- uniform view to edit shell data.
# --------------------------------------------------

class acorn.shells.EditView extends acorn.shells.EditView

  className: 'acorn-shell-edit'

  # Defines the html template for this view.
  # To be overridden in derived classes.
  template: _.template('')

  initialize: =>
    super()
    @eventhub.on 'change:shell', this.OnChangeShell
    @eventhub.on 'swap.shell', this.onSwapShell
    @

  render: =>
    @$el.html @template()

  isEditing: acorn.util.property false

  # Can prevent saves from happening. For instance, this is useful when
  # swapping shells. The swapped-out should not save.
  shouldSave: acorn.util.property false

  onChangeShell: =>
    @render()

  onSwapShell: =>
    @shouldSave false

  finalizeEdit: =>
