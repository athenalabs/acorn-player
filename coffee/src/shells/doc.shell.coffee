goog.provide 'acorn.shells.DocShell'
goog.require 'acorn.shells.TextShell'


TextShell  = acorn.shells.TextShell


DocShell = acorn.shells.DocShell =

  id: 'acorn.DocShell'
  title: 'Doc'
  description: 'a rendered document'
  icon: 'icon-align-justify'



class DocShell.Model extends TextShell.Model


  language: @property('language', default: 'markdown')



# Renders the text
class DocShell.MediaView extends TextShell.MediaView


  className: @classNameExtend 'doc-shell'


  initialize: =>
    super

    render = (doc) -> doc
    if @model.language() is 'markdown'
      render = athena.lib.DocView.renderMarkdown

    @docView = new athena.lib.DocView
      eventhub: @eventhub
      render: render
      doc: @model.text()

  render: =>
    super
    @$el.empty()
    @$el.append @docView.render().el
    @



# uniform view to edit shell data.
class DocShell.RemixView extends TextShell.RemixView


  className: @classNameExtend 'doc-shell row-fluid'

  # TODO: pick language


acorn.registerShellModule DocShell
