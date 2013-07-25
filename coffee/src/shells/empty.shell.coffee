`import "shell"`
`import "../views/shell_selector_view"`
`import "../config"`



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
      eventhub: @eventhub

    @listenTo @selectorView, 'ShellSelector:Selected', (view, shellid) =>
      NewShell = acorn.shellModuleWithId shellid
      if NewShell
        @trigger 'Remix:SwapShell', @model, new NewShell.Model


  render: =>
    super
    @$el.empty()
    @$el.append @selectorView.render().el
    @


  @activeLinkInput: true



acorn.registerShellModule EmptyShell
