goog.provide 'acorn.shells.EmptyShell'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.player.ShellSelectorView'
goog.require 'acorn.config'



Shell = acorn.shells.Shell


EmptyShell = acorn.shells.EmptyShell =

  id: 'acorn.EmptyShell'
  title: 'Empty'
  description: 'an empty, nutless shell'
  icon: 'icon-link'



class EmptyShell.Model extends Shell.Model



class EmptyShell.MediaView extends Shell.MediaView


  className: @classNameExtend 'empty-shell'


  render: =>
    super
    @$el.empty()
    @$el.append('this acorn is empty :(')
    @


class EmptyShell.RemixView extends Shell.RemixView


  className: @classNameExtend 'empty-shell'


  initialize: =>
    super
    @selectorView = new acorn.player.ShellSelectorView


  render: =>
    super
    @$el.empty()
    @$el.append @selectorView.render().el
    @


acorn.registerShellModule EmptyShell
