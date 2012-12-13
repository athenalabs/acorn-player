goog.provide 'acorn.player.ShellOptionsView'

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
    placeholder = ['Playlist', 'Spliced Video', 'Video Collage']
    @dropdownView = new acorn.player.DropdownView items: placeholder

  render: =>
    super
    @$el.empty()
    @$el.append @dropdownView.render().el
    @
