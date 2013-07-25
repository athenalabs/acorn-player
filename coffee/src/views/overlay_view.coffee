
# view with media control buttons
class acorn.player.OverlayView extends athena.lib.View


  overlayTemplate: _.template '''
    <div class="background">
      <div class="content"></div>
    </div>
    '''


  className: @classNameExtend 'overlay-view'


  render: =>
    super
    @$el.empty()

    @$el.append @overlayTemplate()
    @content = @$ '.content'

    @
