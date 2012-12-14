goog.provide 'acorn.shells.Shell'

goog.require 'acorn.shells.Registry'
goog.require 'acorn.Model'
goog.require 'acorn.util'
goog.require 'acorn.errors'


Shell = acorn.shells.Shell

# The unique `shell` name of an acorn Shell.
# The convention is to namespace by vendor. e.g. `acorn.Document`.
Shell.id = 'acorn.Shell'

# Returns a simple title of the shell
# Override it with your own shell-specific code.
Shell.title = 'Shell'

# Description of the shell
Shell.description = 'base shell'


class Shell.Model extends Backbone.Model

  # disable Backbone's sync functionality
  sync: => NotSupportedError 'Backbone::sync'

  # ensure clone is deeply-copied, as acorn data is a multilevel object
  # this approach to deep-copy is ok because all our data should be
  # JSON serializable.
  #
  # See https://github.com/documentcloud/underscore/issues/162 as to why
  # underscore does not implement deep copy.
  clone: => return new @.constructor JSON.parse @toJSONString()

  toJSONString: => return JSON.stringify @toJSON()


  # -- factory constructors --

  @withAcorn: (acornModel) => @withData acornModel.shellData()

  @withData: (data) =>
    if data.shellid?
      shellClass = _.find acorn.shells, (shell) ->
        shell.id == data.shellid

    unless shellClass?
      UnregisteredShellError data.shellid

    new shellClass.Model _.clone data


# register convenience construction functions globally.
acorn.shellWithAcorn = Shell.Model.withAcorn
acorn.shellWithData = Shell.Model.withData

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

class Shell.ContentView extends athena.lib.View

  className: @::className + ' acorn-shell'

  controls: []

  initialize: =>
    super
    @eventhub.on 'playback:play', @onPlaybackPlay
    @eventhub.on 'playback:stop', @onPlaybackStop

    unless @options.controlsView
      acorn.errors.MissingParameterError 'ShellContentView', 'controlsView'

    @controlsView = @options.controlsView
    @controlsView.setControls _.clone @controls

  remove: =>
    @eventhub.off 'playback:play', @onPlaybackPlay
    @eventhub.off 'playback:stop', @onPlaybackStop
    super

  onPlaybackPlay: =>
  onPlaybackStop: =>



# Shell.RemixView -- uniform view to edit shell data.
# --------------------------------------------------

class Shell.RemixView extends athena.lib.View

  className: @::className + ' acorn-shell-edit'

  # Defines the html template for this view.
  # To be overridden in derived classes.
  template: _.template('')

  initialize: =>
    super
    @eventhub.on 'change:shell', this.OnChangeShell
    @eventhub.on 'swap.shell', this.onSwapShell

  render: =>
    @$el.html @template()
    @

  isEditing: acorn.util.property false

  # Can prevent saves from happening. For instance, this is useful when
  # swapping shells. The swapped-out should not save.
  shouldSave: acorn.util.property false

  onChangeShell: =>
    @render()

  onSwapShell: =>
    @shouldSave false

  finalizeEdit: =>


acorn.registerShellModule Shell
