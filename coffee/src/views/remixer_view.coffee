`import "dropdown_view"`
`import "../shells/shell"`

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
      <div class="input-append">
        <div class="btn-group dropdown-view"></div>
      </div>
      <div class="toolbar"></div>
    </div>
    <div class="alert"></div>
    <div class="remixer-summary"></div>
    <div class="remixer-content"></div>
    '''


  events: => _.extend super,
    'blur input#link': @onBlurInput
    'keyup input#link': @onKeyupInput


  defaults: => _.extend super,

    # toolbar buttons
    toolbarButtons: [
      {id:'Clear', icon: 'icon-undo', tooltip: 'Clear'}
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

    @_initializeDropdownView()

    # set toolbar buttons, thereby initializing toolbar view
    @setToolbarButtons()

    if @options.showSummary
      @summarySubview = new acorn.player.EditSummaryView
        eventhub: @eventhub
        model: @model

    @_initializeRemixSubview()


  _initializeDropdownView: =>

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


  _initializeToolbarView: =>
    @toolbarView?.destroy()

    @toolbarView = new athena.lib.ToolbarView
      eventhub: @eventhub
      buttons: @toolbarButtons
      extraClasses: ['btn-group']

    @toolbarView.on 'all', =>
      unless /Toolbar:Click:/.test arguments[0]
        return
      @trigger 'Remixer:' + arguments[0], @

    @toolbarView.on 'Toolbar:Click:Clear', =>
      @swapShell new EmptyShell.Model


  _initializeRemixSubview: =>
    @remixSubview = new @model.module.RemixView
      eventhub: @eventhub
      model: @model

    @remixSubview.on 'Remix:SwapShell', (oldShell, newShell) =>
      @swapShell newShell



  render: =>
    super
    @$el.empty()

    @$el.html @template()
    @alert() # hide

    # keep a pointer to this remixer's link field container in order to
    # disambiguate between that of nested remixers
    @$linkContainer = @$el.children('.remixer-header').children '.input-append'

    @dropdownView.setElement(@$('.dropdown-view').first()).render()

    @renderToolbarView()
    @renderInputField()
    @renderSummarySubview()
    @renderRemixSubview()

    @


  renderToolbarView: =>
    buttonCount = @toolbarButtons.length
    if buttonCount > 0
      @$('.toolbar').first().append @toolbarView.render().el
    @$('.remixer-header').first().attr 'data-button-count', buttonCount


  renderInputField: =>
    shell = @model.module
    @$linkContainer.children('#link').remove()

    if shell.RemixView.activeLinkInput
      placeholder = 'enter link to media (e.g. a youtube video, image, or pdf)'
      @$linkContainer.removeClass 'input-prepend'
      @$linkContainer.prepend "<input id='link' type='text'
          placeholder='#{placeholder}'/>"
      @$linkContainer.children('input#link').val @model.link?()

    else
      @$linkContainer.addClass 'input-prepend'
      @$linkContainer.prepend '<span id="link" class="add-on uneditable-input">
          </span>'
      linkSpanText = "#{shell.title} - #{shell.description}"
      @$linkContainer.children('span#link').text linkSpanText


  renderSummarySubview: =>
    unless @options.showSummary
      return

    unless @model is @summarySubview.model
      @summarySubview.setModel @model

    if @rendering
      @$('.remixer-summary').first().empty()
      @$('.remixer-summary').first().append @summarySubview.render().el

    @


  renderRemixSubview: =>
    unless @model is @remixSubview.model
      @remixSubview?.destroy()
      @_initializeRemixSubview()

    if @rendering
      @$('.remixer-content').first().empty()
      @$('.remixer-content').first().append @remixSubview.render().el

    @$el.removeClass 'empty'
    if @model.module is EmptyShell
      @$el.addClass 'empty'

    @


  swapShell: (newShell) =>
    oldShell = @model
    @model = newShell

    @dropdownView.selected @model.shellid()
    @renderInputField()
    @renderSummarySubview()
    @renderRemixSubview()

    @trigger 'Remixer:SwapShell', @, oldShell, newShell
    @remixSubview.trigger 'Remix:SwappedShell', oldShell, newShell

    @


  shellIsValid: (shell) =>
    _.any @options.validShells, (ValidShell) =>
      shell instanceof ValidShell.Model


  setToolbarButtons: (buttons) =>
    @toolbarButtons = buttons ? @options.toolbarButtons
    @_initializeToolbarView()

    if @rendering
      @renderToolbarView()


  alert: (text, className='error') =>
    alert = @$('.alert').first()
    alert.text(text)
    alert.removeClass('alert-error')
    alert.removeClass('alert-success')
    @$('.remixer-header').first().removeClass 'error'
    @$('.remixer-header').first().removeClass 'success'
    unless text
      alert.hide()
      return

    @$('.remixer-header').first().addClass className
    alert.addClass("alert-#{className}")
    alert.show()


  onKeyupInput: (event) =>
    # discriminate nested input fields
    unless event.target == @$linkContainer.children('input#link')[0]
      return

    switch event.keyCode
      when athena.lib.util.keys.ENTER
        @onLinkChange()
      when athena.lib.util.keys.ESCAPE
        @$linkContainer.children('input#link').val @model.link?() ? ''
        @onLinkChange()


  onBlurInput: (event) =>
    # discriminate nested input fields
    unless event.target == @$linkContainer.children('input#link')[0]
      return

    @onLinkChange()


  onLinkChange: =>
    @alert() # hide
    link = @$linkContainer.children('input#link').val().trim()
    link = acorn.util.urlFix link
    encodedLink = encodeURI(link)

    # idempotent
    if link is @model.link?()
      return

    if link is ''
      # cancel link change if no empty links
      unless @options.allowEmptyLink
        @$linkContainer.children('input#link').val @model.link?()
        return

      @model.link link
      @renderRemixSubview()

    else if acorn.util.isUrl encodedLink
      shell = LinkShell.Model.withLink encodedLink

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
    @$linkContainer.children('input#link').val @model.link?()

    # advertise link change
    @trigger 'Remixer:LinkChanged', @, @model.link?()
