goog.provide 'acorn.shells.ImageLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util'



LinkShell = acorn.shells.LinkShell


ImageLinkShell = acorn.shells.ImageLinkShell =

  id: 'acorn.ImageLinkShell'
  title: 'Image'
  description: 'an embedded image'
  icon: 'icon-picture'
  validLinkPatterns: [ acorn.util.urlRegEx '.*\.(jpg|jpeg|gif|png|svg)' ]



# -- module classes --

class ImageLinkShell.Model extends LinkShell.Model


  defaultAttributes: =>
    superDefaults = super

    _.extend superDefaults,
      thumbnail: @link()



class ImageLinkShell.MediaView extends LinkShell.MediaView


  className: @classNameExtend 'image-link-shell'


  render: =>
    super
    @$el.empty()
    img = $('<img>').attr 'src', @model.get 'link'
    @$el.append img
    @



class ImageLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'image-link-shell'


  render: =>
    super
    @$el.empty()
    img = $('<img>').attr 'src', @model.get 'link'
    @$el.append img
    @



acorn.registerShellModule ImageLinkShell
