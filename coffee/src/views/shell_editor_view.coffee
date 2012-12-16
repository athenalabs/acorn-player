goog.provide 'acorn.player.ShellEditorView'

goog.require 'acorn.player.ShellOptionsView'
goog.require 'acorn.player.RemixerView'

# acorn player ShellEditorView:
#   ------------------------------------------
#   | > |  Type of Media                 | v |
#   ------------------------------------------
#
#   ------------------------------------------
#   | > |  http://link.to.media          | v |
#   ------------------------------------------
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   |                                        |
#   ------------------------------------------


# View to edit a shell. Renders shells' RemixViews.
class acorn.player.ShellEditorView extends athena.lib.View

  className: @classNameExtend 'shell-editor-view'

  initialize: =>
    super

    @shellOptionsView = new acorn.player.ShellOptionsView
      model: @model
      eventhub: @eventhub

    @newRemixerView = new acorn.player.RemixerView
      model: @model
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    @$el.append @shellOptionsView.render().el
    @$el.append @newRemixerView.render().el

    @
