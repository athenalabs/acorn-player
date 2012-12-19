goog.provide 'acorn.player.RemixerView'

goog.require 'acorn.player.DropdownView'
goog.require 'acorn.shells.LinkShell'


TextShell = acorn.shells.TextShell
EmptyShell = acorn.shells.EmptyShell

LinkShell = acorn.shells.LinkShell
PDFLinkShell = acorn.shells.PDFLinkShell
ImageLinkShell = acorn.shells.ImageLinkShell


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
    modules = [
      {id:LinkShell.id, name:'Link (iframe)', icon: LinkShell.icon}
      {id:ImageLinkShell.id, name:'Image Link', icon: ImageLinkShell.icon}
      {id:PDFLinkShell.id, name:'PDF Link', icon: PDFLinkShell.icon}
      # '---' divisors TODO
      {id:TextShell.id, name:'Text', icon: TextShell.icon}
      # '---' divisors TODO
      {id:EmptyShell.id, name:'Empty', icon: EmptyShell.icon}
    ]

    selected = @model.module.id
    if selected == Shell.id
      selected = LinkShell.id

    @dropdownView = new acorn.player.DropdownView
      items: modules
      selected: selected
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

    @dropdownView.setElement @$ '.dropdown-view'
    @dropdownView.render()

    @toolbarView.setElement @$ '.toolbar-view'
    @toolbarView.render()

    @$('input#link').val @model.link?()
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

    @$('input#link').val @model.link?()
    @dropdownView.selected @model.shellid()
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
