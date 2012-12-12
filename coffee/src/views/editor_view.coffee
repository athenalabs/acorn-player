goog.provide 'acorn.player.EditorView'

# View to edit an acorn. Renders shells' EditorViews.
class acorn.player.EditorView extends athena.lib.View

  className: 'acorn-player-edit'

  template: _.template '''
    '''

  initialize: =>
    @player = @options.player
