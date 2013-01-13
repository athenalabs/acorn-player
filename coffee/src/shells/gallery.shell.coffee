goog.provide 'acorn.shells.GalleryShell'

goog.require 'acorn.shells.SlideshowShell'



SlideshowShell = acorn.shells.SlideshowShell


GalleryShell = acorn.shells.GalleryShell =

  id: 'acorn.GalleryShell'
  title: 'GalleryShell'
  description: 'Gallery shell'
  icon: 'icon-th'



class GalleryShell.Model extends SlideshowShell.Model



class GalleryShell.MediaView extends SlideshowShell.MediaView


  className: @classNameExtend 'gallery-shell'



class GalleryShell.RemixView extends SlideshowShell.RemixView


  className: @classNameExtend 'gallery-shell'



acorn.registerShellModule GalleryShell
