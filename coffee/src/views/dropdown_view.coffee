goog.provide 'acorn.player.DropdownView'



# View to select options.
class acorn.player.DropdownView extends athena.lib.View


  className: @classNameExtend 'dropdown-view'


  template: _.template '''
    <button class="btn dropdown-toggle" data-toggle="dropdown" href="#">
      <% if (selected.icon) { %>
        <i class="icon-<%= selected.icon.replace(/^icon-/, '') %>"></i>
      <% } %>
      <span class="dropdown-selected">
        <%= selected.name || selected.id %>
      </span>
      <span class="caret"></span>
    </button>
    <ul class="dropdown-menu pull-right">
      <% _.each(items, function(item) { %>
        <li><a class="dropdown-link" dropdown-id="<%= item.id %>" href="#">
          <% if (item.icon) { %>
            <i class="icon-<%= item.icon.replace(/^icon-/, '') %>"></i>
          <% } %>
          <%= item.name || item.id %>
          <% if (item.id == selected.id) { %>
            <i class="icon-ok"></i>
          <% } %>
        </a></li>
      <% }) %>
    </ul>
    '''


  events: => _.extend super,
    'click a.dropdown-link': (event) =>
      @selected $(event.target).attr('dropdown-id')
      event.preventDefault()


  defaults: => _.extend super,
    disabled: false


  initialize: =>
    super
    unless @options.items.length > 0
      ValueError 'options.items', 'must have at least one item'

    @disabled @options.disabled
    @items = _.map @options.items, @formatItem
    @_selected = @options.selected ? @items[0].id


  render: =>
    super
    @$el.empty()

    @$el.html @template
      selected: @itemWithId @selected()
      items: @items

    if @_disabled
      @$('.dropdown-toggle').attr 'disabled', 'disabled'
      @$('.dropdown-toggle').addClass 'btn-disabled'

    @


  selected: (id) =>
    if id?
      id = String(id).trim()
      unless @itemWithId(id)
        ValueError(id, 'not in items')
      @_selected = id
      @softRender()
      @trigger 'Dropdown:Selected', @, @_selected
    @_selected ? @items[0]


  disabled: (disabled) =>
    if disabled?
      @_disabled = disabled
      @softRender()
    return @_disabled


  itemWithId: (id) =>
    _.find(@items, (item) => item.id == id)


  formatItem: (item) ->
    if _.isString item then {'id': item} else item
