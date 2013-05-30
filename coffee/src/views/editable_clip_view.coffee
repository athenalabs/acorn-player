goog.provide 'acorn.player.EditableClipView'
goog.require 'acorn.player.ClipView'


class acorn.player.EditableClipView extends acorn.player.ClipView


  className: @classNameExtend 'editable-clip-view'


  template: _.template '''
    <textarea class="clip-note tooltip-inner"><%= title %></textarea>
    '''

  events: => _.extend super,
    'focus textarea': =>
      @toolbarView.$('#Edit').hide()
      @toolbarView.$('#Edit-Save').show()
    'blur textarea': =>
      @toolbarView.$('#Edit').hide()
      @toolbarView.$('#Edit-Save').show()


  defaults: => _.extend super,
    # toolbar buttons
    toolbarButtons: [
      {id:'Clip', icon: 'icon-cut', tooltip: 'Clip Time'}
      {id:'Clip-Save', icon: 'icon-ok', tooltip: 'Save New Time', className: 'btn-success'}
      {id:'Edit', icon: 'icon-edit', tooltip: 'Edit Note'}
      {id:'Edit-Save', icon: 'icon-ok', tooltip: 'Save Note', className: 'btn-success'}
      {id:'Delete', icon: 'icon-trash', tooltip: 'Delete Highlight'}
    ]

  render: =>
    super
    @toolbarView.$('#Clip-Save').hide()
    @toolbarView.$('#Edit-Save').hide()
    @


  save: =>
    @model.title = @$('textarea').first().val().trim()
    @render()


  clipping: (isClipping) =>
    @setActive isClipping
    if isClipping
      @toolbarView.$('#Clip').hide()
      @toolbarView.$('#Clip-Save').show()
    else
      @toolbarView.$('#Clip').show()
      @toolbarView.$('#Clip-Save').hide()
