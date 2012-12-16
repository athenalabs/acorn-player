goog.provide 'acorn.shells.ImageLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util'

LinkShell = acorn.shells.LinkShell

ImageLinkShell = acorn.shells.ImageLinkShell =

  id: 'acorn.ImageLinkShell'
  title: 'ImageLinkShell'
  description: 'Shell to contain web based images.'
  icon: 'icon-picture'
  validLinkPatterns: [ acorn.util.urlRegEx '.*\.(jpg|jpeg|gif|png|svg)' ]


# -- module classes --

class ImageLinkShell.Model extends LinkShell.Model



class ImageLinkShell.MediaView extends LinkShell.MediaView

  template: _.template '<div class="wrapper"></div>'

  render: =>
    img = $('<img>').attr 'src', @model.get 'link'
    @$el.html @template()
    @$el.find('.wrapper').append img
    @



class ImageLinkShell.RemixView extends LinkShell.RemixView



acorn.registerShellModule ImageLinkShell
