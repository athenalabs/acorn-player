goog.provide 'acorn.player.SplashView'

# Rendered first, with thumbnail, and icons.
# Meant to load quickly, to make many Players cheap to render.
class acorn.player.SplashView extends athena.lib.View

  className: 'acorn-player-splash'

  template: _.template '''
    <img id="image" src="<= image %>" />
    <img id="type" src="<%= type %>" class="thumbnail-icon" />
    <img id="logo" src="<%= logo %>" class="thumbnail-icon" />
    '''

  initialize: =>
    @player = @options.player

  render: =>
    @$el.empty()

    @$el.html @template
      type: "#{acorn.config.url.img}/icons/#{@player.shell.type}.png"
      logo: "#{acorn.config.url.img}/acorn.png"
      image: @player.shell.thumbnailLink()
