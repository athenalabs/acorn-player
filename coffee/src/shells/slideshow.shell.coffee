goog.provide 'acorn.shells.SlideshowShell'

goog.require 'acorn.shells.CollectionShell'



CollectionShell = acorn.shells.CollectionShell


SlideshowShell = acorn.shells.SlideshowShell =

  id: 'acorn.SlideshowShell'
  title: 'SlideshowShell'
  description: 'Slideshow shell'
  icon: 'icon-play-circle'



class SlideshowShell.Model extends CollectionShell.Model



class SlideshowShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'slideshow-shell'



class SlideshowShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'slideshow-shell'



acorn.registerShellModule SlideshowShell
