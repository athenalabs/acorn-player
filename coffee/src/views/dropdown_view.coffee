goog.provide 'acorn.player.DropdownView'

# View to select options.
class acorn.player.DropdownView extends athena.lib.View

  className: 'dropdown-view span12'

  template: _.template '''
    <button class="btn dropdown-toggle" data-toggle="dropdown" href="#">
      <% if (selected.icon) { %>
        <i class="icon-<%= selected.icon %>"></i>
      <% } %>
      <%= selected.name %>
      <span class="caret" style="float: right;"></span>
    </button>
    <ul class="dropdown-menu">
      <% _.each(items, function(item) { %>
        <li><a href="#">
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

  initialize: =>
    super
    unless @options.items.length > 0
      ValueError 'options.items', 'must have at least one item'

  render: =>
    super
    @$el.empty()

    # transform strings into proper objects
    items = _.map @options.items, (item) ->
      if _.isString item then {'name': item} else item

    @$el.html @template
      selected: (@options.selected ? items[0])
      items: items
    @
