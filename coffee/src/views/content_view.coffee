goog.provide 'acorn.player.ContentView'

# View to experience an acorn. Renders shells' ContentViews, and the controls.
class acorn.player.ContentView extends athena.lib.View

  className: 'acorn-player-content'

  template: _.template '''
    '''

  initialize: =>
    @player = @options.player
