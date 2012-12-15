goog.provide 'acorn.shells.TextShell'

goog.require 'acorn.shells.Shell'

Shell = acorn.shells.Shell
TextShell = acorn.shells.TextShell

TextShell.id = 'acorn.TextShell'
TextShell.title = 'TextShell'
TextShell.description = 'a shell to store text'


class TextShell.Model extends Shell.Model

# {
#   "shellid": "acorn.TextShell",
#   "text": "the text to store"
# }


# Renders the text
class TextShell.ContentView extends Shell.ContentView

  className: @classNameExtend 'text-shell'

  render: =>
    super
    @$el.empty()
    @$el.text @model.get 'text'

# uniform view to edit shell data.
class TextShell.RemixView extends Shell.RemixView

  className: @classNameExtend 'text-shell row-fluid'

  template: _.template '''
    <textarea class="span12"><%= text %></textarea>
    '''

  render: =>
    super
    @$el.empty()
    @$el.html @template @model.attributes


acorn.registerShellModule TextShell
