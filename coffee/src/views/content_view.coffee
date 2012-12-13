goog.provide 'acorn.player.ContentView'

# View to experience an acorn. Renders shells' ContentViews, and the controls.
class acorn.player.ContentView extends athena.lib.View

  className: 'content-view'

  initialize: =>
    # should these go here?
    # @model.shellModel.on 'change', @render
    # @model.acornModel.on 'change', @render

    @shellView = new @model.shellModel.shell.ContentView
      model: @model.shellModel
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    @$el.append @shellView.render().el

    #TODO add controls
    @
