goog.provide 'acorn.player.OverlayView'

# ** player.OverlayView ** view with media control buttons
# ---------------------------------------------------------
class acorn.player.OverlayView extends athena.lib.View

  overlayTemplate: _.template '''
    <div class="clear-cover"></div>
    <div class="background"></div>
    <div class="content"></div>
    '''

  className: @::className + ' overlay'

  render: =>
    @$el.empty()

    @$el.append @overlayTemplate()
    @content = @$ '.content'

    @
