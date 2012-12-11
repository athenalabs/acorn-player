goog.provide 'acorn.player.ContentView'

# View to experience an acorn. Renders shells' ContentViews, and the controls.
class acorn.player.ContentView extends athena.lib.View

  className: 'content-view'

  render: =>
    super()
    @shellView?.destroy()
    @$el.empty()

    @shellView = new @model.shellModel.shell.ContentView
      model: @model.shellModel
      eventhub: @eventhub

    @shellView.render()
    @$el.append @shellView.el

    #TODO add controls
