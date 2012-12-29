goog.provide 'acorn.player.AcornOptionsView'



# acorn player AcornOptionsView:
#   ----------
#   |        |    acornid:
#   |        |    [ title                    ]
#   ----------


# View to edit acorn options.

class acorn.player.AcornOptionsView extends athena.lib.View


  className: @classNameExtend 'acorn-options-view'


  events: => _.extend super,
    'blur #title': => @model.set title: @$('#title').val()


  template: _.template '''
    <div class="row-fluid">
      <div class="span2">
        <div class="thumbnail-view">
          <img class="img-rounded" src="<%= thumbnail %>" />
        </div>
      </div>
      <div class="span10">
        <h4 id="acornid">
          <% if (acornid && acornid != 'new') { %>
            acornid:<%= acornid %>
          <% } else { %>
            create a new acorn
          <% } %>
        </h4>
        <input id="title" type="text" value="<%= title %>"
          placeholder="enter a description" class="span9" />
      </div>
    </div>
    '''


  render: =>
    super
    @$el.empty()
    @$el.html @template @model.attributes
    @
