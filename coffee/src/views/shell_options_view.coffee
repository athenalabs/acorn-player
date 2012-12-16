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

  className: @classNameExtend 'shell-options-view row-fluid'

  initialize: =>
    super

    modules = _.map acorn.shells.Registry.modules, (module, shellid) =>
      {id:module.id, name: module.title, icon: module.icon}

    @dropdownView = new acorn.player.DropdownView
      items: modules
      selected: @model.module.id

    @dropdownView.on 'Dropdown:Selected', =>
      @model.set shellid: @dropdownView.selected()

  render: =>
    super
    @$el.empty()
    @$el.append @dropdownView.render().el
    @
