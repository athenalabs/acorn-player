`import "../shells/shell"`
`import "../shells/shell"`
`import "dropdown_view"`
`import "edit_summary_view"`

# acorn player ShellOptionsView:
#
#   ------------------------------------------
#   | > |  Type of Media                 | v |
#   ------------------------------------------
#   |            shell.OptionsView           |
#   ------------------------------------------
#
# View to edit shell options.

class acorn.player.ShellOptionsView extends athena.lib.View


  className: @classNameExtend 'shell-options-view'


  initialize: =>
    super

    modules = _.map acorn.shells.Registry.collectionModules(), (m) =>
      {id:m.id, name: m.title, icon: m.icon}

    @dropdownView = new acorn.player.DropdownView
      eventhub: @eventhub
      items: modules
      selected: @model.module.id

    @dropdownView.on 'Dropdown:Selected', =>
      shellid = @dropdownView.selected()
      unless shellid is @model.shellid()
        @trigger 'ShellOptions:SwapShell', shellid

    @summaryView = new acorn.player.EditSummaryView
      eventhub: @eventhub
      model: @model

    @remixView = new @model.module.RemixView
      eventhub: @eventhub
      model: @model


  render: =>
    super
    @$el.empty()
    @$el.append @dropdownView.render().el
    @$el.append @summaryView.render().el
    @$el.append @remixView.render().el
    @
