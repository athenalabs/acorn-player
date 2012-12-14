goog.provide 'acorn.player.RemixerView'

goog.require 'acorn.player.DropdownView'

# View to select options.
class acorn.player.RemixerView extends athena.lib.View

  className: @::className + ' remixer-view'

  template: _.template '''
    <div class="input-prepend row-fluid">
      <div class="btn-group dropdown-view"></div>
      <input class="span6" id="link" type="text">
    </div>
    <div class="remixer-content"></div>
    '''

  initialize: =>
    super

    @dropdownView = new acorn.player.DropdownView
      items: [
        {name: '', icon: ''},
        {name: 'Link', icon: 'share'},
        {name: 'Video Link', icon: 'play'}
      ]
      selected: 'Link'


  render: =>
    super
    @$el.empty()

    @$el.html @template()

    @dropdownView.setElement @$ '.dropdown-view'
    @dropdownView.render()

    if @remixerSubview
      @$('.remixer-content').append @remixerSubview.render().el

    @
