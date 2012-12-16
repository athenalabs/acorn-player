goog.provide 'acorn.shells.EmptyShell'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.config'

Shell = acorn.shells.Shell

EmptyShell = acorn.shells.EmptyShell =

  id: 'acorn.EmptyShell'
  title: 'EmptyShell'
  description: 'an empty, nutless shell'
  icon: 'icon-check-empty'


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
