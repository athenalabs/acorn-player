goog.provide 'acorn.player.AcornOptionsView'

# acorn player AcornOptionsView:
#   ----------
#   |        |    acornid:
#   |        |    [ title                    ]
#   ----------


# View to edit acorn options.
class acorn.player.AcornOptionsView extends athena.lib.View

  className: 'acorn-options-view'

  template: _.template '''
    <div class="row-fluid">
      <div class="thumbnail-view span2">
        <img class="img-rounded" src="<%= thumbnail %>" />
      </div>
      <div class="span10">
        <h4 id="acornid">acornid:<%= acornid %></h4>
        <input id="title" type="text" value="<%= title %>"
          placeholder="Title" class="large" />
      </div>
    </div>
    '''

  render: =>
    super
    @$el.empty()
    @$el.html @template @model.attributes
