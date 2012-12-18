goog.provide 'acorn.shells.PDFLinkShell'

goog.require 'acorn.shells.LinkShell'

LinkShell = acorn.shells.LinkShell

PDFLinkShell = acorn.shells.PDFLinkShell =

  id: 'acorn.PDFLinkShell'
  title: 'PDFLinkShell'
  description: 'Shell to contain web based PDF documents.'
  icon: 'icon-pdf'
  validLinkPatterns: [ acorn.util.urlRegEx '.*\.pdf' ]


# -- module classes --

class PDFLinkShell.Model extends LinkShell.Model

  thumbnail: =>
    acorn.util.imgUrl('thumbnails/pdf.png')


class PDFLinkShell.MediaView extends LinkShell.MediaView


class PDFLinkShell.RemixView extends LinkShell.RemixView


acorn.RegisterShellModule PDFLinkShell
