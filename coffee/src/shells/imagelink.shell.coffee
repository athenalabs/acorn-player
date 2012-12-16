goog.provide 'acorn.shells.ImageLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util'

LinkShell = acorn.shells.LinkShell
ImageLinkShell = acorn.shells.ImageLinkShell

# -- module properties --
# Properties in this section should be overriden by all
# shell modules based on ImageLinkShell

# ImageLinkShell module properties
ImageLinkShell.id = 'acorn.ImageLinkShell'
ImageLinkShell.title = 'ImageLinkShell'
ImageLinkShell.description = 'Shell to contain web based images.'
ImageLinkShell.icon = 'icon-picture'

# This property lists the set of regular expression patterns
# that LinkShell matches. It should be extended or overriden
# in shells that inherit from LinkShell.
ImageLinkShell.validLinkPatterns = [
  acorn.util.urlRegEx '.*\.(jpg|jpeg|gif|png|svg)'
]


# -- module classes --

class ImageLinkShell.Model extends LinkShell.Model



class ImageLinkShell.ContentView extends LinkShell.ContentView

  template: _.template '<div class="wrapper"></div>'

  render: =>
    img = $('<img>').attr 'src', @model.get 'link'
    @$el.html @template()
    @$el.find('.wrapper').append img
    @



class ImageLinkShell.RemixView extends LinkShell.RemixView



acorn.registerShellModule ImageLinkShell
