goog.provide 'acorn.specs.player.ShellOptionsView'

goog.require 'acorn.player.ShellOptionsView'

describe 'acorn.player.ShellOptionsView', ->
  ShellOptionsView = acorn.player.ShellOptionsView

  # shell model for ShellOptionsView contruction
  model = new Backbone.Model
    shellid: 'acorn.Shell'

  # options for ShellOptionsView contruction
  options = model: model

  it 'should be part of acorn.player', ->
    expect(acorn.player.ShellOptionsView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ShellOptionsView, athena.lib.View).toBe true

  describe 'ShellOptionsView::dropdownView subview', ->

    it 'should be defined on init', ->
      view = new ShellOptionsView options
      expect(view.dropdownView).toBeDefined()

    it 'should be an instanceof DropdownView', ->
      view = new ShellOptionsView options
      expect(view.dropdownView instanceof acorn.player.DropdownView)

    it 'should not be rendering initially', ->
      view = new ShellOptionsView options
      expect(view.dropdownView.rendering).toBe false

    it 'should be rendering with DropdownView', ->
      view = new ShellOptionsView options
      view.render()
      expect(view.dropdownView.rendering).toBe true

    it 'should be a DOM child of the DropdownView', ->
      view = new ShellOptionsView options
      view.render()
      expect(view.dropdownView.el.parentNode).toEqual view.el

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
