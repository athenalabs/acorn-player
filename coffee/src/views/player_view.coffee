goog.provide 'acorn.player.PlayerView'

goog.require 'acorn.player.EditorView'
goog.require 'acorn.player.SplashView'
goog.require 'acorn.player.ContentView'
goog.require 'acorn.player.OverlayView'
goog.require 'acorn.player.SourcesView'
goog.require 'acorn.player.TimeInputView'
goog.require 'acorn.player.TimeRangeInputView'
goog.require 'acorn.player.CycleButtonView'



# Main view. Container for the other three main views.
class acorn.player.PlayerView extends athena.lib.ContainerView


  className: @classNameExtend 'player-view row-fluid'


  events: => _.extend super,
    'keydown': (event) =>
      name = _.invert(athena.lib.util.keys)[event.keyCode]
      @eventhub.trigger "Keypress:#{name}"
      console.log "triggered Keypress:#{name} " + event.keyCode
      event.preventDefault()
      return false


  initialize: =>
    super

    unless @model instanceof acorn.Model
      TypeError @model, 'acorn.Model'

    # ensure acorn defines valid shellModel
    shellModel = acorn.shellWithAcorn @model
    unless shellModel instanceof acorn.shells.Shell.Model
      TypeError shellModel, 'acorn.shells.Shell.Model'

    @editable !!@options.editable

    @eventhub.on 'show:editor', =>
      unless @editable() then return
      @content @editorView()
      @$el.attr 'showing', 'editor'

    @eventhub.on 'show:splash', =>
      @content @splashView()
      @$el.attr 'showing', 'splash'

    @eventhub.on 'show:content', =>
      @content @contentView()
      @$el.attr 'showing', 'content'

    @eventhub.on 'Editor:Saved', @onSave
    @eventhub.on 'Editor:Cancel', =>
      unless @editable()
        return
      @_editorView?.destroy()
      @_editorView = undefined
      @content @contentView()

    @eventhub.on 'EditControl:Click', =>
      if @editable()
        @eventhub.trigger 'show:editor'

    @eventhub.on 'AcornControl:Click', => @openAcornWebsite()
    @eventhub.on 'SourcesControl:Click', => @eventhub.trigger 'show:sources'
    @eventhub.on 'FullscreenControl:Click', => @enterFullscreen()


  render: =>
    super
    @$el.attr 'tabindex', '-1'
    @


  contentView: =>
    @_contentView ?= new acorn.player.ContentView
      eventhub: @eventhub
      model: @model
    @_contentView


  splashView: =>
    @_splashView ?= new acorn.player.SplashView
      eventhub: @eventhub
      model: @model
    @_splashView


  editorView: =>
    unless @editable()
      return

    @_editorView ?= new acorn.player.EditorView
      eventhub: @eventhub
      model: @model.clone()
    @_editorView


  editable: (editable) =>
    if editable?
      @_editable = editable

      # adjust editable class
      if @_editable
        @$el.addClass 'editable'
        @$el.removeClass 'uneditable'
      else
        @$el.removeClass 'editable'
        @$el.addClass 'uneditable'

    @_editable


  onSave: =>
    unless @editable()
      return

    @model.set @_editorView.model.attributes

    # clear previous contentView to force reload, then show
    @_contentView?.destroy()
    @_contentView = undefined
    @eventhub.trigger 'show:content'

    # clear editorView
    @_editorView?.destroy()
    @_editorView = undefined


  enterFullscreen: =>
    acorn.util.fullscreen @$el.parent()


  openAcornWebsite: =>
    window.open @model.pageUrl(), '_blank'
