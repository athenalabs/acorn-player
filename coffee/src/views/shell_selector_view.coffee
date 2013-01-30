goog.provide 'acorn.player.ShellSelectorView'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.shells.CollectionShell'


CollectionShell = acorn.shells.CollectionShell

class acorn.player.ShellSelectorView extends athena.lib.View


  className: @classNameExtend 'shell-selector-view'


  events: => _.extend super,
    'click a': (event) => event.preventDefault()


  template: _.template '''
    <div class="row-fluid select-divider">
      <hr class="span4"></hr>
      <div class="span4 align-center">or select other type below</div>
      <hr class="span4"></hr>
    </div>
    '''


  initialize: =>
    super

    @modules ?= [TextShell, VideoLinkShell]
    tileModels = _.map @modules, (Shell) =>
      new Backbone.Model
        text: Shell.title
        icon: Shell.icon
        shell: Shell.id

    @gridView = new athena.lib.GridView
      collection: new Backbone.Collection tileModels
      eventhub: @eventhub

    @listenTo @gridView, 'GridTile:Click', (tile) =>
      @select tile.model.get 'shell'


  render: =>
    super
    @$el.empty()
    @$el.html @template()
    @$el.append @gridView.render().el
    @


  select: (shellid) =>
    @trigger 'ShellSelector:Selected', @, shellid
