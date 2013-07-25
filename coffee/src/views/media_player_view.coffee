`import "../media"`
`import "../util/"`


class acorn.player.MediaPlayerView extends athena.lib.View


  # mixin acorn.MediaInterface
  _.extend @prototype, acorn.MediaInterface.prototype


  className: @classNameExtend 'media-player-view'


  initialize: =>
    super
    @initializeMediaEvents @options
    @setMediaState 'init'


  render: =>
    super
    @$el.empty()
    # TODO: this embedding method primarily does not work
    @$el.append "<embed src='#{@model.get 'link'}'/>"
    @
