goog.provide 'acorn.shells.PDFLinkShell'

goog.require 'acorn.shells.LinkShell'



LinkShell = acorn.shells.LinkShell


PDFLinkShell = acorn.shells.PDFLinkShell =

  id: 'acorn.PDFLinkShell'
  title: 'PDF'
  description: 'an embedded PDF document'
  icon: 'icon-file'
  validLinkPatterns: [ acorn.util.urlRegEx '.*\.pdf' ]


# -- module classes --

class PDFLinkShell.Model extends LinkShell.Model




class PDFLinkShell.MediaView extends LinkShell.MediaView


  className: @classNameExtend 'pdf-shell'



class PDFLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'pdf-shell'



acorn.registerShellModule PDFLinkShell
