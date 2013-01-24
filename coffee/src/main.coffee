goog.provide 'acorn.player.main'

goog.require 'acorn.player.Player'
goog.require 'acorn.config'
goog.require 'acorn.util'
goog.require 'acorn.util.test'
goog.require 'acorn.MediaInterface'
goog.require 'acorn'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.shells.TextShell'
goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.PDFLinkShell'
goog.require 'acorn.shells.ImageLinkShell'
goog.require 'acorn.shells.AcornLinkShell'
goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.shells.YouTubeShell'
goog.require 'acorn.shells.VimeoShell'
goog.require 'acorn.shells.CollectionShell'
goog.require 'acorn.shells.SlideshowShell'
goog.require 'acorn.shells.GalleryShell'

goog.require 'acorn.player.MediaPlayerView'
goog.require 'acorn.player.TimedMediaPlayerView'
goog.require 'acorn.player.SummaryView'

(exports ? @).acorn = acorn
