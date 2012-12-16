goog.provide 'acorn.specs.player.ShellOptionsView'

goog.require 'acorn.player.ShellOptionsView'

describe 'acorn.player.ShellOptionsView', ->
  ShellOptionsView = acorn.player.ShellOptionsView

  # shell model for ShellOptionsView contruction
  model = new acorn.shells.Shell.Model
    shellid: 'acorn.Shell'

  # options for ShellOptionsView contruction
  options = model: model

  it 'should be part of acorn.player', ->
    expect(ShellOptionsView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ShellOptionsView, athena.lib.View, options

  athena.lib.util.test.describeSubview
    View: ShellOptionsView
    Subview: acorn.player.DropdownView
    subviewAttr: 'dropdownView'
    viewOptions: options

  it 'should change shell.shellid on Dropdown:Selected', ->
    view = new ShellOptionsView options
    view.render()
    expect(view.model.get 'shellid').toBe 'acorn.Shell'
    view.dropdownView.selected('acorn.EmptyShell')
    expect(view.model.get 'shellid').toBe 'acorn.EmptyShell'

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a ShellOptionsView into the DOM to see how it looks.
    model = new Backbone.Model

    view = new ShellOptionsView options
    view.$el.width 600
    view.$el.height 200
    view.render()
    $player.append view.el
