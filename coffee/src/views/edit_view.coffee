goog.provide 'acorn.player.EditView'

# View to edit an acorn. Renders shells' EditViews.
class acorn.player.EditView extends athena.lib.View

  className: 'acorn-player-edit'

  template: _.template '''
    '''

  initialize: =>
    @player = @options.player
