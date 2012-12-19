goog.provide 'acorn.player.RemixerView'

goog.require 'acorn.player.DropdownView'
goog.require 'acorn.shells.LinkShell'

# View to select options.
class acorn.player.RemixerView extends athena.lib.View

  className: @::className + ' remixer-view row-fluid'

  template: _.template '''
    <div class="row-fluid remixer-header">
      <div class="input-append">
        <input id="link" type="text" placeholder="enter link" />
        <div class="btn-group dropdown-view"></div>
      </div>
      <div class="btn-group toolbar-view"></div>
    </div>
    <div class="remixer-content"></div>
    <hr />
    '''

  events: => _.extend super,
    'click button#duplicate': => @trigger 'Remixer:Duplicate', @
    'click button#delete': => @trigger 'Remixer:Delete', @
    'blur input#link': @onBlurLink

  initialize: =>
    super

    unless @model instanceof acorn.shells.Shell.Model
      TypeError @model, 'Shell.Model'

    @initializeDropdownView()

    @toolbarView = new athena.lib.ToolbarView
      eventhub: @eventhub
      buttons: [
        {id:'duplicate', icon: 'icon-copy', tooltip: 'Duplicate'}
        {id:'delete', icon: 'icon-remove', tooltip: 'Delete'}
      ]

    @remixSubview = new @model.module.RemixView
      eventhub: @eventhub
      model: @model


  initializeDropdownView: =>

    # get only the Link-based Modules
    linkModules = _.filter acorn.shells.Registry.modules, (module) =>
      !!module.id.match 'Link'

    # construct dropdown items
    items = _.map linkModules, (module, shellid) =>
      {id:module.id, name: module.title, icon: module.icon}

    @dropdownView = new acorn.player.DropdownView
      items: items
      selected: LinkShell.id
      eventhub: @eventhub

    @dropdownView.on 'Dropdown:Selected', (dropdown, value) =>
      unless value is @model.shellid()
        @swapShell Shell.Model.withData
          shellid: value
          link: @model.link()


  render: =>
    super
    @$el.empty()

    @$el.html @template()

    @$('input#link').val @model.link?()

    @dropdownView.setElement @$ '.dropdown-view'
    @dropdownView.render()

    @toolbarView.setElement @$ '.toolbar-view'
    @toolbarView.render()

    @renderRemixSubview()

    @

  renderRemixSubview: =>
    unless @model is @remixSubview.model
      @remixSubview?.destroy()
      @remixSubview = new @model.module.RemixView
        eventhub: @eventhub
        model: @model

    if @rendering
      @$('.remixer-content').append @remixSubview.render().el

    @

  swapShell: (newShell) =>
    oldShell = @model
    @model = newShell
    @renderRemixSubview()
    @trigger 'Remixer:SwapShell', @, oldShell, newShell
    @

  onBlurLink: (event) =>
    link = @$('input#link').val().trim();

    if acorn.util.isUrl link
      shell = LinkShell.Model.withLink link
      if shell instanceof Shell.Model and shell.shellid() != @model.shellid()
        @swapShell shell
      else
        @model.link link
        @remixSubview.render()

    # set link to whatever our model is
    @$('input#link').val @model.link?()
