goog.provide 'acorn.player.ContentView'

# View to experience an acorn. Renders shells' ContentViews, and the controls.
class acorn.player.ContentView extends athena.lib.View

  className: 'content-view'

  render: =>
    super()
    @shellView?.destroy()
    @$el.empty()

    @shellView = new @model.shell.ContentView
      model: @model
      eventhub: @eventhub

    @shellView.render()
    @$el.append @shellView.el

    #TODO add controls
