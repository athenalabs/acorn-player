goog.provide 'acorn.specs.player.controls.ControlToolbarView'

goog.require 'acorn.player.controls.ControlToolbarView'
goog.require 'acorn.player.controls.ControlView'
goog.require 'acorn.player.controls.IconControlView'
goog.require 'acorn.player.controls.ImageControlView'


describe 'acorn.player.controls.ControlToolbarView', ->
  EventSpy = athena.lib.util.test.EventSpy
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

  it 'should forward all button events', ->
    btns = [new ControlView, new ControlView, new ControlView]
    tbar = new ControlToolbarView buttons: btns
    spy = new EventSpy tbar, 'all'
    btns[0].trigger 'hi'
    expect(spy.triggerCount).toBe 1
    btns[1].trigger 'hello'
    expect(spy.triggerCount).toBe 2
    btns[2].trigger 'i'
    expect(spy.triggerCount).toBe 3
    btns[1].trigger 'am'
    expect(spy.triggerCount).toBe 4
    btns[0].trigger 'pah'
    expect(spy.triggerCount).toBe 5

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


describe 'acorn.player.controls.ImageControlView', ->
  ControlView = acorn.player.controls.ControlView
  ImageControlView = acorn.player.controls.ImageControlView

  describeView = athena.lib.util.test.describeView
  describeView ImageControlView, ControlView

  it 'should be part of acorn.player.controls', ->
    expect(ImageControlView).toBeDefined()

  describe 'ImageControlView.withUrl', ->
    it 'should be a function', ->
      expect(typeof ImageControlView.withUrl).toBe 'function'

    it 'should construct controls', ->
      image = ImageControlView.withUrl acorn.config.img.acorn
      expect(image instanceof ImageControlView).toBe true

    it 'should set the icon property', ->
      url = acorn.config.img.acorn
      image = ImageControlView.withUrl url
      expect(image.url).toBe url

    it 'should ensure param is a string url', ->
      expect(-> ControlView.withIcon 1).toThrow()
      expect(-> ControlView.withIcon []).toThrow()
      expect(-> ControlView.withIcon {}).toThrow()
      expect(-> ControlView.withIcon ->).toThrow()
      expect(-> ControlView.withIcon 'fdsiojfdpos').toThrow()
      expect(-> ControlView.withIcon 'play').toThrow()

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    _.each [acorn.config.img.acornIcon], (url) ->
      view = ImageControlView.withUrl url
      view.render()
      $player.append view.el
