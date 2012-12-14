goog.provide 'acorn.player.ContentView'

# View to experience an acorn. Renders shells' ContentViews, and the controls.
class acorn.player.ContentView extends athena.lib.View

  className: @classNameExtend 'content-view'

  initialize: =>
    # should these go here?
    # @model.shellModel.on 'change', @render
    # @model.acornModel.on 'change', @render

    @controlsView = new acorn.player.ControlsView
      eventhub: @eventhub

    @shellView = new @model.shellModel.shell.ContentView
      model: @model.shellModel
      controlsView: @controlsView.shellControls
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    # add controlsView to DOM first so that shellView can interact with it
    @$el.append @controlsView.render().el
    @$el.prepend @shellView.render().el

    @
