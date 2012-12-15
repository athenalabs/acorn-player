goog.provide 'acorn.player.controls.ControlToolbarView'
goog.provide 'acorn.player.controls.ControlView'

goog.require 'acorn.config'


# view with media control buttons
class ControlToolbarView extends athena.lib.ToolbarView

  className: @classNameExtend 'control-toolbar-view'

  initialize: =>
    super

    # construct any ControlViews referenced by id
    @buttons = _.map @buttons, (btn) =>
      if _.isString btn then ControlView.withId btn else btn

    # ensure all toolbar buttons are Controls or ControlToolbars
    _.each @buttons, (btn) =>
      unless btn instanceof ControlToolbarView or btn instanceof ControlView
        TypeError 'button', "ControlToolbarView or ControlView"


class ControlView extends athena.lib.View

  className: @classNameExtend 'control-view'

  events: => _.extend super,
    'click': => @trigger 'Control:Click', @

  @withId: (id) =>
    cls = "#{id}ControlView"
    View = acorn.player.controls[cls]
    unless athena.lib.util.derives View, ControlView
      ControlNotFoundError id
    new View


acorn.player.controls.ControlToolbarView = ControlToolbarView
acorn.player.controls.ControlView = ControlView
