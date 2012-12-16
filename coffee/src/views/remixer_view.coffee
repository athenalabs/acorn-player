goog.provide 'acorn.player.RemixerView'

goog.require 'acorn.player.DropdownView'

# View to select options.
class acorn.player.RemixerView extends athena.lib.View

  className: @::className + ' remixer-view'

  template: _.template '''
    <div class="input-append row-fluid">
      <input class="span9" id="link" type="text" />
      <div class="btn-group dropdown-view"></div>
    </div>
    <div class="remixer-content"></div>
    '''

  initialize: =>
    super

    @dropdownView = new acorn.player.DropdownView
      items: [
        {id: '', icon: ''},
        {id: 'Link', icon: 'share'},
        {id: 'Video Link', icon: 'play'}
      ]
      selected: 'Link'
      eventhub: @eventhub

  render: =>
    super
    @$el.empty()

    @$el.html @template()

    @dropdownView.setElement @$ '.dropdown-view'
    @dropdownView.render()

    if @remixerSubview
      @$('.remixer-content').append @remixerSubview.render().el

    @
