goog.provide 'acorn.player.SplashView'



# Rendered first, with thumbnail, and icons.
# Meant to load quickly, to make many Players cheap to render.
class acorn.player.SplashView extends athena.lib.View


  className: @classNameExtend 'splash-view'


  events: => _.extend super,
    'click': => @eventhub.trigger 'show:content'


  template: _.template '''
    <img id="image" src="<%= image %>" class="splash-image" />
    <i id="type" class="<%= type %> splash-icon"></i>
    <img id="logo" src="<%= logo %>" class="splash-icon" />
    '''


  initialize: =>
    super

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'


  render: =>
    super
    @$el.empty()

    shellid = @model.shellData().shellid
    module = acorn.shellModuleWithId(shellid)

    @$el.html @template
      type: module.icon
      logo: "#{acorn.config.url.img}/acorn.png"
      image: @model.thumbnail()

    @$('#image').objectFit 'contain'

    @
