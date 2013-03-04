goog.provide 'acorn.player.RemixerView'

goog.require 'acorn.player.DropdownView'
goog.require 'acorn.shells.LinkShell'



TextShell = acorn.shells.TextShell
EmptyShell = acorn.shells.EmptyShell

LinkShell = acorn.shells.LinkShell
PDFLinkShell = acorn.shells.PDFLinkShell
ImageLinkShell = acorn.shells.ImageLinkShell
AcornLinkShell = acorn.shells.AcornLinkShell

# View to select options.
class acorn.player.RemixerView extends athena.lib.View


  className: @classNameExtend 'remixer-view row-fluid'


  template: _.template '''
    <div class="row-fluid control-group remixer-header">
    <% if (activeLink) { %>
      <div class="input-append">
        <input id="link" type="text" placeholder="enter link" />
    <% } else { %>
      <div class="input-prepend input-append">
        <span id="link" class="add-on uneditable-input"><%= linkFieldText
            %></span>
    <% } %>
        <div class="btn-group dropdown-view"></div>
      </div>
      <div class="btn-group toolbar-view"></div>
    </div>
    <div class="alert"></div>
    <div class="remixer-content"></div>
    '''


  events: => _.extend super,
    'blur input#link': => @onLinkChange()
    'keyup input#link': @onKeyupInput


  defaults: => _.extend super,

    # toolbar buttons
    toolbarButtons: [
      {id:'Duplicate', icon: 'icon-copy', tooltip: 'Duplicate'}
      {id:'Delete', icon: 'icon-remove', tooltip: 'Delete'}
    ]

    # show summary view
    showSummary: true

    # allow empty link
    allowEmptyLink: false

    # restrict the possible shells - default to all
    validShells: _.values acorn.shells.Registry.modules


  initialize: =>
    super

    unless @model instanceof acorn.shells.Shell.Model
      TypeError @model, 'Shell.Model'

    @initializeDropdownView()

    @toolbarView = new athena.lib.ToolbarView
      eventhub: @eventhub
      buttons: @options.toolbarButtons

    @toolbarView.on 'all', =>
      unless /Toolbar:Click:/.test arguments[0]
        return
      @trigger 'Remixer:' + arguments[0], @

    if @options.showSummary
      @summarySubview = new acorn.player.EditSummaryView
        eventhub: @eventhub
        model: @model

    @remixSubview = new @model.module.RemixView
      eventhub: @eventhub
      model: @model

    @remixSubview.on 'Remix:SwapShell', (oldShell, newShell) =>
      @swapShell newShell


  initializeDropdownView: =>

    moduleObject = (Shell) ->
      {id:Shell.id, name:Shell.title, icon:Shell.icon}

    # get only the Link-based Modules
    modules = [
      moduleObject(LinkShell)
      moduleObject(AcornLinkShell)
      moduleObject(ImageLinkShell)
      moduleObject(PDFLinkShell)
      moduleObject(YouTubeShell)
      moduleObject(VimeoShell)
      # '---' divisors TODO
      moduleObject(TextShell)
      moduleObject(DocShell)
      # '---' divisors TODO
      moduleObject(EmptyShell)
    ]

    selected = @model.module.id
    if selected == Shell.id
      selected = EmptyShell.id

    @dropdownView = new acorn.player.DropdownView
      items: modules
      selected: selected
      eventhub: @eventhub
      disabled: true

    @dropdownView.on 'Dropdown:Selected', (dropdown, value) =>
      unless value is @model.shellid()
        @swapShell Shell.Model.withData
          shellid: value
          link: @model.link()


  render: =>
    super
    @$el.empty()

    @$el.html @template
      activeLink: @model.module.RemixView.activeLinkInput
      linkFieldText: "#{@model.module.title} - #{@model.module.description}"
    @alert() # hide

    @dropdownView.setElement(@$('.dropdown-view')).render()

    if @options.toolbarButtons.length > 0
      @toolbarView.setElement(@$('.toolbar-view')).render()

    @$('input#link').val @model.link?()
    @renderSummarySubview()
    @renderRemixSubview()

    @


  renderSummarySubview: =>
    unless @options.showSummary
      return

    unless @model is @summarySubview.model
      @summarySubview.setModel @model

    unless @model.module is acorn.shells.EmptyShell
      if @rendering
        @$('.remixer-content').before @summarySubview.render().el

    @


  renderRemixSubview: =>
    unless @model is @remixSubview.model
      @remixSubview?.destroy()
      @remixSubview = new @model.module.RemixView
        eventhub: @eventhub
        model: @model

    if @rendering
      @$('.remixer-content').append @remixSubview.render().el

    @$el.removeClass 'empty'
    @toolbarView.$('.btn').removeClass 'disabled'
    if @model.module is acorn.shells.EmptyShell
      @$el.addClass 'empty'
      @toolbarView.$('.btn').addClass 'disabled'

    @


  swapShell: (newShell) =>
    oldShell = @model
    @model = newShell

    @$('input#link').val @model.link?()
    @dropdownView.selected @model.shellid()
    @renderSummarySubview()
    @renderRemixSubview()

    @trigger 'Remixer:SwapShell', @, oldShell, newShell
    @

  shellIsValid: (shell) =>
    _.any @options.validShells, (ValidShell) =>
      shell instanceof ValidShell.Model


  alert: (text, className='error') =>
    alert = @$('.alert')
    alert.text(text)
    alert.removeClass('alert-error')
    alert.removeClass('alert-success')
    @$('.remixer-header').removeClass 'error'
    @$('.remixer-header').removeClass 'success'
    unless text
      alert.hide()
      return

    @$('.remixer-header').addClass className
    alert.addClass("alert-#{className}")
    alert.show()


  onKeyupInput: (event) =>
    switch event.keyCode
      when athena.lib.util.keys.ENTER
        @onLinkChange()
      when athena.lib.util.keys.ESCAPE
        @$('input#link').val @model.link?() ? ''
        @onLinkChange()


  onLinkChange: =>
    @alert() # hide
    link = @$('input#link').val().trim()
    link = acorn.util.urlFix link

    # idempotent
    if link is @model.link?()
      return

    if link is ''
      # cancel link change if no empty links
      unless @options.allowEmptyLink
        @$('input#link').val @model.link?()
        return

      @model.link link
      @renderRemixSubview()

    else if acorn.util.isUrl link
      shell = LinkShell.Model.withLink link

      unless @shellIsValid shell
        console.log 'invalid shell'
        shellNames = _.pluck @options.validShells, 'title'
        @alert 'Invalid link. Enter a link to: ' + shellNames.join(', ')
        return

      if shell instanceof Shell.Model and shell.shellid() != @model.shellid()
        @swapShell shell
      else
        @model.link link
        @renderRemixSubview()

    # set link to whatever our model is
    @$('input#link').val @model.link?()

    # advertise link change
    @trigger 'Remixer:LinkChanged', @, @model.link?()
