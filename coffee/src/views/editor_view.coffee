goog.provide 'acorn.player.EditorView'

goog.require 'acorn.player.AcornOptionsView'

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

  render: =>
    super
    @$el.empty()

    @acornOptionsView.render()
    @$el.append @acornOptionsView.el
