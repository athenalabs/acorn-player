goog.provide 'acorn.player.controls.ControlToolbarView'
goog.provide 'acorn.player.controls.ControlView'
goog.provide 'acorn.player.controls.IconControlView'
goog.provide 'acorn.player.controls.ImageControlView'

goog.require 'acorn.config'



# view with media control buttons
class ControlToolbarView extends athena.lib.ToolbarView


  className: @classNameExtend 'control-toolbar-view'


  initialize: =>
    super
    @initializeButtons()

  initializeButtons: =>

    # construct any ControlViews referenced by id
    @buttons = _.map @buttons, (btn) =>
      if _.isString btn then ControlView.withId btn else btn

    # ensure all toolbar buttons are Controls or ControlToolbars
    _.each @buttons, (btn) =>
      unless btn instanceof ControlToolbarView or btn instanceof ControlView
        TypeError 'button', "ControlToolbarView or ControlView"

    # forward all events from buttons
    _.each @buttons, (btn) =>
      btn.on 'all', (eventName) => @trigger eventName



class ControlView extends athena.lib.View


  controlName: => 'Control'


  className: @classNameExtend 'control-view'


  tooltip: =>


  events: => _.extend super,
    'click': => @trigger "#{@controlName()}:Click", @


  render: =>
    super
    tooltip = @tooltip()
    if tooltip
      @$el.tooltip(tooltip)
    @


  @withId: (id) =>
    cls = "#{id}ControlView"
    View = acorn.player.controls[cls]
    unless athena.lib.util.derives View, ControlView
      ControlNotFoundError id
    new View



class IconControlView extends ControlView


  controlName: => 'IconControl'


  className: @classNameExtend 'icon-control-view'


  initialize: =>
    super
    @icon = @options.icon ? 'play'


  render: =>
    super
    @$el.html $('<i>').addClass "icon-#{@icon}"
    @


  @withIcon: (icon) =>
    unless _.isString icon
      TypeError 'icon', 'string'

    new IconControlView icon: icon



class FullscreenControlView extends IconControlView
  controlName: => 'FullscreenControl'
  className: @classNameExtend 'fullscreen'
  tooltip: => title: 'Fullscreen', delay: show: 1500
  defaults: => _.extend super,
    icon: 'fullscreen'



class EditControlView extends IconControlView
  controlName: => 'EditControl'
  className: @classNameExtend 'edit'
  tooltip: => title: 'Edit', delay: show: 1500
  defaults: => _.extend super,
    icon: 'edit'



class SourcesControlView extends IconControlView
  controlName: => 'SourcesControl'
  className: @classNameExtend 'sources'
  tooltip: => title: 'Sources', delay: show: 1500
  defaults: => _.extend super,
    icon: 'globe'



class PreviousControlView extends IconControlView
  controlName: => 'PreviousControl'
  className: @classNameExtend 'previous'
  tooltip: => title: 'Previous', delay: show: 1500
  defaults: => _.extend super,
    icon: 'arrow-left'



class NextControlView extends IconControlView
  controlName: => 'NextControl'
  className: @classNameExtend 'next'
  tooltip: => title: 'Next', delay: show: 1500
  defaults: => _.extend super,
    icon: 'arrow-right'



class ImageControlView extends ControlView


  controlName: => 'ImageControl'


  className: @classNameExtend 'image-control-view'


  initialize: =>
    super
    @url = @options.url ? acorn.config.img.acorn


  render: =>
    super
    @$el.html $('<img>').attr 'src', @url
    @


  @withUrl: (url) =>
    unless acorn.util.isUrl(url) or acorn.util.isPath(url)
      TypeError url, 'string url'

    new ImageControlView url: url



class AcornControlView extends ImageControlView
  controlName: => 'AcornControl'
  className: @classNameExtend 'acorn'
  tooltip: => title: 'Website', delay: show: 1500
  defaults: => _.extend super,
    image: acorn.config.img.acornIcon



acorn.player.controls.ControlToolbarView = ControlToolbarView
acorn.player.controls.ControlView = ControlView

acorn.player.controls.IconControlView = IconControlView
acorn.player.controls.EditControlView = EditControlView
acorn.player.controls.SourcesControlView = SourcesControlView
acorn.player.controls.FullscreenControlView = FullscreenControlView

acorn.player.controls.NextControlView = NextControlView
acorn.player.controls.PreviousControlView = PreviousControlView

acorn.player.controls.ImageControlView = ImageControlView
acorn.player.controls.AcornControlView = AcornControlView
