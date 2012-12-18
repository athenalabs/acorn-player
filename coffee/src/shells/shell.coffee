goog.provide 'acorn.shells.Shell'

goog.require 'acorn.shells.Registry'
goog.require 'acorn.Model'
goog.require 'acorn.util'
goog.require 'acorn.errors'


Shell = acorn.shells.Shell =

  # The unique `shell` name of an acorn Shell.
  # The convention is to namespace by vendor. e.g. `acorn.Document`.
  id: 'acorn.Shell'

  # Returns a simple title of the shell
  # Override it with your own shell-specific code.
  title: 'Shell'

  # Description of the shell
  description: 'base shell'

  # Basic icon to display throughout (using Font Awesome classes)
  icon: 'icon-sign-blank'


class Shell.Model extends athena.lib.Model

  # disable Backbone's sync functionality
  sync: => NotSupportedError 'Backbone::sync'

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


class Shell.MediaView extends athena.lib.View

  className: @classNameExtend 'shell-content-view'

  controls: []

  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.MediaView', 'model'



# Shell.RemixView -- uniform view to edit shell data.
# --------------------------------------------------

class Shell.RemixView extends athena.lib.View

  className: @classNameExtend 'shell-remix-view'

  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.RemixView', 'model'


acorn.registerShellModule Shell
