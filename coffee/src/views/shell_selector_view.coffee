goog.provide 'acorn.player.ShellSelectorView'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.shells.CollectionShell'


CollectionShell = acorn.shells.CollectionShell

class acorn.player.ShellSelectorView extends athena.lib.View


  className: @classNameExtend 'shell-selector-view'


  events: => _.extend super,
    'click a': (event) => event.preventDefault()



  template: _.template '''
    <div class="row-fluid">
      <hr class="span5"></hr>
      <div class="span1 align-center">or</div>
      <hr class="span5"></hr>
    </div>
    <div>Select a shell below:</div>
    '''


  initialize: =>
    super

    @modules ?= [TextShell, VideoLinkShell]
    tileModels = _.map @modules, (Shell) =>
      new Backbone.Model
        text: Shell.title
        icon: Shell.icon
        link: Shell.id

    @gridView = new athena.lib.GridView
      collection: new Backbone.Collection tileModels
      eventhub: @eventhub

    @listenTo @gridView, 'GridTile:Click', (tile) =>
      @trigger 'ShellSelector:Selected', @, tile.model.get 'link'


  render: =>
    super
    @$el.empty()
    @$el.html @template()
    @$el.append @gridView.render().el
    @
