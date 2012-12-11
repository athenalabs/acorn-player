goog.provide 'acorn.player.SplashView'

# Rendered first, with thumbnail, and icons.
# Meant to load quickly, to make many Players cheap to render.
class acorn.player.SplashView extends athena.lib.View

  className: 'splash-view'

  events: => _.extend super(),
    'click image': 'onClickImage'

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

    # Preserve image aspect ratio but contain it wholly
    # See https://github.com/schmidsi/jquery-object-fit
    # setTimeout bypasses https://github.com/schmidsi/jquery-object-fit/issues/3
    setTimeout (-> @$('#image').objectFit 'contain'), 200

    @

  onClickImage: => @eventhub.trigger 'Splash:Advance'
