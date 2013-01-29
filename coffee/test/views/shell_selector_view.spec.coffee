goog.provide 'acorn.specs.player.ShellSelectorView'

goog.require 'acorn.player.ShellSelectorView'

describe 'acorn.player.ShellSelectorView', ->
  test = athena.lib.util.test
  ShellSelectorView = acorn.player.ShellSelectorView

  test.describeView ShellSelectorView, athena.lib.View

  it 'should be part of acorn.player', ->
    expect(ShellSelectorView).toBeDefined()

  test.describeSubview {
    View: ShellSelectorView
    Subview: athena.lib.GridView
    subviewAttr: 'gridView'
  }, ->

    it 'should trigger `ShellSelector:Selected` on `GridTile:Click`', ->
      tile = {model: new Backbone.Model {link: 'foo'}}
      view = new ShellSelectorView
      spy = new test.EventSpy view, 'ShellSelector:Selected'
      view.render()
      view.gridView.trigger 'GridTile:Click', tile
      expect(spy.triggered).toBe true

    it 'should trigger `ShellSelector:Selected` with view and tile.link', ->
      tile = {model: new Backbone.Model {link: 'foo'}}
      view = new ShellSelectorView
      spy = new test.EventSpy view, 'ShellSelector:Selected'
      view.render()
      view.gridView.trigger 'GridTile:Click', tile
      expect(spy.arguments[0]).toEqual [view, 'foo']


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a ShellSelectorView into the DOM to see how it looks.
    view = new ShellSelectorView
    view.render()
    $player.append view.el
