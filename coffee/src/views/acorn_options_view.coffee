goog.provide 'acorn.player.AcornOptionsView'
goog.require 'acorn.config'


# acorn player AcornOptionsView:
#   ----------
#   |        |    acornid:
#   |        |    [ title                    ]
#   ----------


# View to edit acorn options.

class acorn.player.AcornOptionsView extends athena.lib.View


  className: @classNameExtend 'acorn-options-view'


  events: => _.extend super,
    'blur #title': => @model.set 'title', @$('#title').val()
    'blur #thumbnail': => @model.set 'thumbnail', @$('#thumbnail').val()


  template: _.template '''
    <div class="row-fluid">
      <div class="span3">
        <div class="thumbnail-view">
          <img class="img-rounded" src="<%= thumbnail %>" />
        </div>
      </div>
      <div class="span9">
        <h4 id="acornid">
          <% if (acornid && acornid != 'new') { %>
            acornid:<%= acornid %>
          <% } else { %>
            create a new acorn
          <% } %>
        </h4>
        <input id="title" type="text" value="<%= title %>"
          placeholder="enter a description" class="span9" />
        <input id="thumbnail" type="text" value="<%= thumbnail %>"
          placeholder="enter thumbnail image link" class="span9" />
      </div>
    </div>
    '''


  initialize: =>
    super

    @listenTo @model, 'change:thumbnail', =>
      if @rendering
        @$('.thumbnail-view img').attr 'src', @model.get 'thumbnail'


  render: =>
    super
    @$el.empty()

    variables =
      thumbnail: acorn.config.img.acorn
      acornid: 'new'
      title: ''

    @$el.html @template _.extend variables, @model.attributes
    @
