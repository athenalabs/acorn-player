goog.provide 'acorn.specs.player.controls.ControlToolbarView'

goog.require 'acorn.player.controls.ControlToolbarView'
goog.require 'acorn.player.controls.ControlView'
goog.require 'acorn.player.controls.IconControlView'


describe 'acorn.player.controls.ControlToolbarView', ->
  ControlView = acorn.player.controls.ControlView
  IconControlView = acorn.player.controls.IconControlView
  ControlToolbar = acorn.player.controls.ControlToolbarView

  it 'should be part of acorn.player.controls', ->
    expect(ControlToolbarView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ControlToolbarView, athena.lib.View

  it 'should accept ControlViews', ->
    btns = [new ControlView, new IconControlView]
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should accept ControlToolbarViews', ->
    btns = [new ControlToolbarView, new ControlToolbarView]
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should accept ControlView ids', ->
    btns = ['Icon']
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should not accept other things', ->
    expect(-> new ControlToolbarView buttons: ['NotAControl']).toThrow()
    expect(-> new ControlToolbarView buttons: [new acorn.lib.View]).toThrow()
    expect(-> new ControlToolbarView buttons: [{text: 'Button'}]).toThrow()
    expect(-> new ControlToolbarView buttons: [$('body')]).toThrow()
    expect(-> new ControlToolbarView buttons: [1]).toThrow()

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    btns = ['Icon', 'Icon', 'Icon', 'Icon', 'Icon']
    view = new ControlToolbarView buttons: btns
    view.$el.width 600
    view.render()
    $player.append view.el


describe 'acorn.player.controls.ControlView', ->
  ControlView = acorn.player.controls.ControlView
  IconControlView = acorn.player.controls.IconControlView

  describeView = athena.lib.util.test.describeView
  describeView ControlView, athena.lib.View

  it 'should be part of acorn.player.controls', ->
    expect(ControlView).toBeDefined()

  it 'should have factory constructor `withId`', ->
    expect(typeof ControlView.withId).toBe 'function'

  it 'should construct controls `withId`', ->
    expect(ControlView.withId('Icon') instanceof IconControlView).toBe true


describe 'acorn.player.controls.IconControlView', ->
  ControlView = acorn.player.controls.ControlView
  IconControlView = acorn.player.controls.IconControlView

  describeView = athena.lib.util.test.describeView
  describeView IconControlView, ControlView

  it 'should be part of acorn.player.controls', ->
    expect(IconControlView).toBeDefined()

  describe 'IconControlView.withIcon', ->
    it 'should be a function', ->
      expect(typeof IconControlView.withIcon).toBe 'function'

    it 'should construct controls', ->
      icon = IconControlView.withIcon 'play'
      expect(icon instanceof IconControlView).toBe true

    it 'should set the icon property', ->
      icon = IconControlView.withIcon 'play'
      expect(icon.icon).toBe 'play'

    it 'should ensure param is a string', ->
      expect(-> ControlView.withIcon 1).toThrow()
      expect(-> ControlView.withIcon []).toThrow()
      expect(-> ControlView.withIcon {}).toThrow()
      expect(-> ControlView.withIcon ->).toThrow()

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    _.each ['backward', 'play', 'pause', 'stop', 'forward'], (icon) ->
      view = IconControlView.withIcon icon
      view.render()
      $player.append view.el
