goog.provide 'acorn.player.EditImageView'

goog.require 'acorn.shells.Registry'
goog.require 'acorn.shells.ImageLinkShell'
goog.require 'acorn.player.RemixerView'



# acorn player EditImageView:
#
#   ------------------------------------------
#   | > |  Type of Media                 | v |
#   ------------------------------------------
#   |            shell.OptionsView           |
#   ------------------------------------------
#
# View to edit shell options.

class acorn.player.EditImageView extends athena.lib.View


  className: @classNameExtend 'edit-image-view'


  initialize: =>
    super

    @model ?= new ImageLinkShell.Model
      link: @options.link

    @remixerView = new acorn.player.RemixerView
      eventhub: @eventhub
      model: @model
      showSummary: false
      toolbarButtons: [
        {id:'Cancel', icon: 'icon-remove', tooltip: 'Cancel'}
        {id:'Save', icon: 'icon-ok', tooltip: 'Save'}
      ]
      validShells: [ImageLinkShell]

    @remixerView.on 'Remixer:LinkChanged', (remixer, newlink) =>
      console.log 'Link Changed'

    @remixerView.on 'Remixer:Toolbar:Click:Cancel', =>
      @trigger 'EditImage:Cancel'

    @remixerView.on 'Remixer:Toolbar:Click:Save', =>
      @trigger 'EditImage:Save'


  render: =>
    super
    @$el.empty()
    @$el.append @remixerView.render().el
    @
