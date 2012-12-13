goog.provide 'acorn.player.EditorView'

goog.require 'acorn.player.AcornOptionsView'
goog.require 'acorn.player.ShellOptionsView'

# acorn player EditorView:
# ------------------------------------------------
# |  ----------                                  |
# |  |        |    acornid:                      |
# |  |        |    [ title                    ]  |
# |  ----------                                  |
# |                                              |
# |  ------------------------------------------  |
# |  | > |  Type of Media                 | v |  |
# |  ------------------------------------------  |
# |                                              |
# |  ------------------------------------------  |
# |  | > |  http://link.to.media          | v |  |
# |  ------------------------------------------  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  |                                        |  |
# |  ------------------------------------------  |
# |                                              |
# |                         [ Cancel ] [ Save ]  |
# ------------------------------------------------


# View to edit an acorn. Renders shells' EditorViews.
class acorn.player.EditorView extends athena.lib.View

  className: 'editor-view span8'

  initialize: =>
    super

    @acornOptionsView = new acorn.player.AcornOptionsView
      model: @model.acornModel
      eventhub: @eventhub

    @shellOptionsView = new acorn.player.ShellOptionsView
      model: @model.shellModel
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    @$el.append @acornOptionsView.render().el
    @$el.append @shellOptionsView.render().el
