goog.provide 'acorn.player.DropdownView'

# View to select options.
class acorn.player.DropdownView extends athena.lib.View

  className: @classNameExtend 'dropdown-view span12'

  template: _.template '''
    <button class="btn dropdown-toggle" data-toggle="dropdown" href="#">
      <% if (selected.icon) { %>
        <i class="icon-<%= selected.icon %>"></i>
      <% } %>
      <span class="dropdown-selected"><%= selected.name %></span>
      <span class="caret"></span>
    </button>
    <ul class="dropdown-menu pull-right">
      <% _.each(items, function(item) { %>
        <li><a class="dropdown-link" href="#">
          <% if (item.icon) { %>
            <i class="icon-<%= item.icon %>"></i>
          <% } %>
          <%= item.name %>
          <% if (item.name == selected.name) { %>
            <i class="icon-ok"></i>
          <% } %>
        </a></li>
      <% }) %>
    </ul>
    '''

  events: => _.extend super,
    'click a.dropdown-link': (event) => @selected $(event.target).text()

  initialize: =>
    super
    unless @options.items.length > 0
      ValueError 'options.items', 'must have at least one item'

    @items = _.map @options.items, @formatItem
    @_selected = @options.selected ? @items[0].name

  render: =>
    super
    @$el.empty()

    @$el.html @template
      selected: @itemWithValue @selected()
      items: @items

    @

  selected: (value) =>
    if value?
      value = String(value).trim()
      unless @itemWithValue(value)
        ValueError('value', 'not in items')
      @_selected = value
      @softRender()
      @trigger 'Dropdown:Selected', @, @_selected
    @_selected ? @items[0]

  itemWithValue: (value) =>
    _.find(@items, (item) => item.name == value)

  formatItem: (item) ->
    if _.isString item then {'name': item} else item
