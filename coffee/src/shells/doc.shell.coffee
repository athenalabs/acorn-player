`import "text.shell.js"`


TextShell  = acorn.shells.TextShell


DocShell = acorn.shells.DocShell =

  id: 'acorn.DocShell'
  title: 'Doc'
  description: 'a formatted document'
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
      #render = athena.lib.DocView.renderMarkdown
      render = () =>
        $.ajax({
          type: "POST"
          url: 'https://api.github.com/markdown/raw'
          contentType: "text/plain"
          context: @
          data: @model.text()
          success: (data) ->
            @$el.append data
            @
        })

    @docView = new athena.lib.DocView
      eventhub: @eventhub
      render: render
      doc: @model.text()

  render: =>
    super
    @$el.empty()
    @docView.render()
    @



# uniform view to edit shell data.
class DocShell.RemixView extends TextShell.RemixView


  placeholder: 'enter text here - DocShell text is processed with Markdown'


  className: @classNameExtend 'doc-shell row-fluid'

  # TODO: pick language


acorn.registerShellModule DocShell
