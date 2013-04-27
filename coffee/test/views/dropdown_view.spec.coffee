goog.provide 'acorn.specs.player.DropdownView'

goog.require 'acorn.player.DropdownView'

describe 'acorn.player.DropdownView', ->
  test = athena.lib.util.test
  DropdownView = acorn.player.DropdownView
  EventSpy = athena.lib.util.test.EventSpy

  describeView = athena.lib.util.test.describeView
  describeView DropdownView, athena.lib.View, items: ['Item']

  it 'should be part of acorn.player', ->
    expect(DropdownView).toBeDefined()

  test.describeDefaults DropdownView, {disabled: false}, {items: ['item']}


  it 'should ensure it gets at least one item', ->
    expect(-> new DropdownView()).toThrow()
    expect(-> new DropdownView(items: [])).toThrow()
    expect(-> new DropdownView(items: ['item'])).not.toThrow()

  it 'should be possible to specify a selected item', ->
    items = 'abcdefg'.split ''
    view = new DropdownView(items: items, selected: 'c')
    expect(view.selected()).toBe 'c'

  it 'should not throw error if selecting a nonexistent item', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    expect(-> view.selected('c')).not.toThrow()
    expect(-> view.selected('z')).not.toThrow()

  it 'should create item if selecting a nonexistent item', ->
    view = new DropdownView(items: 'abcdefg'.split '')
    expect(view.selected('z')).toEqual 'z'
    expect(view.itemWithId('z')).toEqual {id:'z', text:'z'}

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

  it 'should render item names, if available', ->
    items = [{id:'a', name:'Aa'}, {id:'b', name:'Bb'}]
    view = new DropdownView items: items
    view.render()

    textInEl = (sel) -> view.$(sel).text().replace(/\s/g, '')
    expect(view.selected()).toBe 'a'
    expect(textInEl('.dropdown-selected')).toBe 'Aa'
    expect(view.selected('b')).toBe 'b'
    expect(textInEl('.dropdown-selected')).toBe 'Bb'
    expect(textInEl('.dropdown-menu')).toBe 'AaBb'

  it 'should render item icons, if available', ->
    items = [{id:'a', icon:'icon-play'}, {id:'b', icon:'icon-stop'}]
    view = new DropdownView items: items
    view.render()

    iconsInEl = (sel) -> view.$(sel).children('i:first-child')
    expect(iconsInEl('.dropdown-toggle').hasClass('icon-play')).toBe true
    expect(iconsInEl('.dropdown-link').eq(0).hasClass('icon-play')).toBe true
    expect(iconsInEl('.dropdown-link').eq(1).hasClass('icon-stop')).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    view = new DropdownView items: [
      {id: 'playlist', name:'Playlist', icon: 'list'},
      {id: 'svideo', name:'Spliced Video', icon: 'play'}
    ]

    view.$el.width 600
    view.render()
    $player.append view.el
