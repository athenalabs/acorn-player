goog.provide 'acorn.shells.TextShell'

goog.require 'acorn.shells.Shell'



Shell = acorn.shells.Shell


TextShell = acorn.shells.TextShell =

  id: 'acorn.TextShell'
  title: 'Text'
  description: 'simple text'
  icon: 'icon-align-left'



class TextShell.Model extends Shell.Model


  text: @property 'text'



# Renders the text
class TextShell.MediaView extends Shell.MediaView


  className: @classNameExtend 'text-shell'


  render: =>
    super
    @$el.empty()

    container = $ '<pre>'
    container.text @model.get 'text'
    @$el.append container

    @



# uniform view to edit shell data.
class TextShell.RemixView extends Shell.RemixView


  className: @classNameExtend 'text-shell row-fluid'


  placeholder: 'enter text here'


  template: _.template '''
    <textarea placeholder="<%= placeholder %>"><%= text %></textarea>
    '''


  events: => _.extend super,
    'keyup textarea': => @model.text @$('textarea').first().val()


  render: =>
    super

    @$el.empty()
    @$el.html @template
      placeholder: @placeholder
      text: @model.get 'text'

    @



acorn.registerShellModule TextShell
