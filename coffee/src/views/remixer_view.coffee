goog.provide 'acorn.player.RemixerView'

goog.require 'acorn.player.DropdownView'

# View to select options.
class acorn.player.RemixerView extends athena.lib.View

  className: @::className + ' remixer-view row-fluid'

  template: _.template '''
    <div class="row-fluid remixer-header span12">
      <div class="input-append">
        <input id="link" type="text" placeholder="enter link" />
        <div class="btn-group dropdown-view"></div>
      </div>
      <div class="btn-group toolbar-view"></div>
    </div>
    <div class="remixer-content span12"></div>
    '''

  events: => _.extend super,
    'click button#duplicate': => @trigger 'Remixer:Duplicate', @
    'click button#delete': => @trigger 'Remixer:Delete', @

  initialize: =>
    super

    unless @model instanceof acorn.shells.Shell.Model
      TypeError @model, 'Shell.Model'

    @dropdownView = new acorn.player.DropdownView
      items: [
        {id: '', icon: ''},
        {id: 'Link', icon: 'share'},
        {id: 'Video Link', icon: 'play'}
      ]
      selected: 'Link'
      eventhub: @eventhub

    @toolbarView = new athena.lib.ToolbarView
      eventhub: @eventhub
      buttons: [
        {id:'duplicate', icon: 'icon-copy', tooltip: 'Duplicate'}
        {id:'delete', icon: 'icon-remove', tooltip: 'Delete'}
      ]

    @remixSubview = new @model.module.RemixView
      eventhub: @eventhub
      model: @model

  render: =>
    super
    @$el.empty()

    @$el.html @template()

    @dropdownView.setElement @$ '.dropdown-view'
    @dropdownView.render()

    @toolbarView.setElement @$ '.toolbar-view'
    @toolbarView.render()

    @$('.remixer-content').append @remixSubview.render().el

    @
