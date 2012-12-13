goog.provide 'acorn.player.ShellOptionsView'

goog.require 'acorn.shells.Registry'
goog.require 'acorn.shells.Shell'
goog.require 'acorn.player.DropdownView'

# acorn player ShellOptionsView:
#
#   ------------------------------------------
#   | > |  Type of Media                 | v |
#   ------------------------------------------
#   |            shell.OptionsView           |
#   ------------------------------------------

# View to edit shell options.
class acorn.player.ShellOptionsView extends athena.lib.View

  className: 'shell-options-view row-fluid'

  initialize: =>
    super
    placeholder = _.keys acorn.shells.Registry.modules
    @dropdownView = new acorn.player.DropdownView
      items: placeholder
      selected: @model.get('shellid')
    @

  render: =>
    super
    @$el.empty()
    @$el.append @dropdownView.render().el
    @
