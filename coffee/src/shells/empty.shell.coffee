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



class EmptyShell.MediaView extends Shell.MediaView


  className: @classNameExtend 'empty-shell'


  render: =>
    @$el.empty()
    @$el.append('this acorn is empty :(')



acorn.registerShellModule EmptyShell
