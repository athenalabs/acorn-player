goog.provide 'acorn.player.SplashView'



# Rendered first, with thumbnail, and icons.
# Meant to load quickly, to make many Players cheap to render.
class acorn.player.SplashView extends athena.lib.View


  className: @classNameExtend 'splash-view'


  events: => _.extend super,
    'click img': => @eventhub.trigger 'show:content'


  template: _.template '''
    <img id="image" src="<%= image %>" class="splash-image" />
    <img id="type" src="<%= type %>" class="splash-icon" />
    <img id="logo" src="<%= logo %>" class="splash-icon" />
    '''


  initialize: =>
    super

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'


  render: =>
    super
    @$el.empty()

    @$el.html @template
      type: "#{acorn.config.url.img}/icons/#{@model.get('type')}.png"
      logo: "#{acorn.config.url.img}/acorn.png"
      image: @model.get 'thumbnail'

    @$('#image').objectFit 'contain'

    @
