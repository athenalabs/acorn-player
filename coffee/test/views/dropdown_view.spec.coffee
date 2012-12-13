goog.provide 'acorn.specs.player.DropdownView'

goog.require 'acorn.player.DropdownView'

describe 'acorn.player.DropdownView', ->
  DropdownView = acorn.player.DropdownView

  it 'should be part of acorn.player', ->
    expect(DropdownView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives DropdownView, athena.lib.View).toBe true

  it 'should ensure it gets at least one item', ->
    expect(-> new DropdownView()).toThrow()
    expect(-> new DropdownView(items: [])).toThrow()
    expect(-> new DropdownView(items: ['item'])).not.toThrow()

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new DropdownView items: ['Playlist', 'Spliced Video']
    view.$el.width 600
    view.render()
    $player.append view.el
