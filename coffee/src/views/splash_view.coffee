goog.provide 'acorn.player.SplashView'

# Rendered first, with thumbnail, and icons.
# Meant to load quickly, to make many Players cheap to render.
class acorn.player.SplashView extends athena.lib.View

  className: 'splash-view'

  events: => _.extend super,
    'click #image': => @eventhub.trigger 'show:content'

  template: _.template '''
    <img id="image" src="<%= image %>" class="splash-image" />
    <img id="type" src="<%= type %>" class="splash-icon" />
    <img id="logo" src="<%= logo %>" class="splash-icon" />
    '''

  render: =>
    @$el.empty()

    @$el.html @template
      type: "#{acorn.config.url.img}/icons/#{@model.get('type')}.png"
      logo: "#{acorn.config.url.img}/acorn.png"
      image: @model.get 'thumbnail'

    @$('#image').objectFit 'contain'

    @
