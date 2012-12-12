goog.provide 'acorn.shells.EmptyShell'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.config'


Shell = acorn.shells.Shell
EmptyShell = acorn.shells.EmptyShell

# The unique `shell` name of an acorn Shell.
# The convention is to namespace by vendor. e.g. `acorn.Document`.
EmptyShell.id = 'acorn.EmptyShell'

# Returns a simple title of the shell
# Override it with your own shell-specific code.
EmptyShell.title = 'EmptyShell'

# Description of the shell
EmptyShell.description = 'an empty, nutless shell'


class EmptyShell.Model extends Shell.Model

  # Returns a remoteResource object whose data() function
  # Caches and returns this Shell's thumbnail link.
  # Stub implementation -- Intended to be overriden by derived classes.
  thumbnailLink: => acorn.config.img.acorn


class EmptyShell.ContentView extends Shell.ContentView

  render: =>
    @$el.empty()
    @$el.append('this acorn is empty :(')

acorn.registerShellModule EmptyShell
