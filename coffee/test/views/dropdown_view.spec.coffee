goog.provide 'acorn.specs.player.DropdownView'

goog.require 'acorn.player.DropdownView'

describe 'acorn.player.DropdownView', ->
  DropdownView = acorn.player.DropdownView
  EventSpy = athena.lib.util.test.EventSpy

  describeView = athena.lib.util.test.describeView
  describeView DropdownView, athena.lib.View, items: ['Item']

  it 'should be part of acorn.player', ->
    expect(DropdownView).toBeDefined()

  it 'should ensure it gets at least one item', ->
    expect(-> new DropdownView()).toThrow()
    expect(-> new DropdownView(items: [])).toThrow()
    expect(-> new DropdownView(items: ['item'])).not.toThrow()

  it 'should be possible to specify a selected item', ->
    items = 'abcdefg'.split ''
    view = new DropdownView(items: items, selected: 'c')
    expect(view.selected()).toBe 'c'

  it 'should throw error if selecting a nonexistent item', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    expect(-> view.selected('c')).not.toThrow()
    expect(-> view.selected('z')).toThrow()

  it 'should change selected on setting selected.', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    expect(view.selected()).toBe 'a'
    expect(view.selected('c')).toBe 'c'
    expect(view.selected()).toBe 'c'

  it 'should set selected on clicking a dropdown link.', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    view.render()

    expect(view.selected()).toBe 'a'
    expect(view.selected('c')).toBe 'c'

    s = spyOn(view, 'selected').andCallThrough()
    view.$('.dropdown-link').first().trigger('click')
    expect(s).toHaveBeenCalled()
    expect(view.selected()).toBe 'a'

  it 'should trigger selected event on setting selected.', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    spy = new EventSpy view, 'Dropdown:Selected'
    expect(spy.triggerCount).toBe 0
    view.selected()
    expect(spy.triggerCount).toBe 0
    view.selected('c')
    expect(spy.triggerCount).toBe 1

  it 'should trigger selected event every time items are selected.', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    spy = new EventSpy view, 'Dropdown:Selected'
    view.selected('c')
    expect(spy.triggerCount).toBe 1
    view.selected('d')
    expect(spy.triggerCount).toBe 2
    view.selected('a')
    expect(spy.triggerCount).toBe 3

  it 'should trigger selected event even when selecting the same item.', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    spy = new EventSpy view, 'Dropdown:Selected'
    view.selected('c')
    expect(spy.triggerCount).toBe 1
    view.selected('c')
    expect(spy.triggerCount).toBe 2
    view.selected('d')
    expect(spy.triggerCount).toBe 3
    view.selected('d')
    expect(spy.triggerCount).toBe 4

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new DropdownView items: [
      {name: 'Playlist', icon: 'list'},
      {name: 'Spliced Video', icon: 'play'}
    ]

    view.$el.width 600
    view.render()
    $player.append view.el
