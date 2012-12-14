goog.provide 'acorn.player.AcornOptionsView'

# acorn player AcornOptionsView:
#   ----------
#   |        |    acornid:
#   |        |    [ title                    ]
#   ----------


# View to edit acorn options.
class acorn.player.AcornOptionsView extends athena.lib.View

  className: @::className + ' acorn-options-view'

  events: => _.extend super,
    'blur #title': => @model.set title: @$('#title').val()

  template: _.template '''
    <div class="row-fluid">
      <div class="span3">
        <div class="thumbnail-view">
          <img class="img-rounded" src="<%= thumbnail %>" />
        </div>
      </div>
      <div class="span9">
        <h4 id="acornid">acornid:<%= acornid %></h4>
        <input id="title" type="text" value="<%= title %>"
          placeholder="Title" class="span9" />
      </div>
    </div>
    '''

  render: =>
    super
    @$el.empty()
    @$el.html @template @model.attributes
    @
