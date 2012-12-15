goog.provide 'acorn.specs.player.controls.ControlToolbarView'

goog.require 'acorn.player.controls.ControlToolbarView'
goog.require 'acorn.player.controls.ControlView'

describe 'acorn.player.controls.ControlToolbarView', ->
  ControlView = acorn.player.controls.ControlView
  ControlToolbar = acorn.player.controls.ControlToolbarView

  it 'should be part of acorn.player.controls', ->
    expect(ControlToolbarView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ControlToolbarView, athena.lib.View

  it 'should accept ControlViews', ->
    btns = [new ControlView, new ControlView]
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should accept ControlToolbarViews', ->
    btns = [new ControlToolbarView, new ControlToolbarView]
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should not accept other things', ->
    expect(-> new ControlToolbarView buttons: ['NotAControl']).toThrow()
    expect(-> new ControlToolbarView buttons: [new acorn.lib.View]).toThrow()
    expect(-> new ControlToolbarView buttons: [{text: 'Button'}]).toThrow()
    expect(-> new ControlToolbarView buttons: [$('body')]).toThrow()
    expect(-> new ControlToolbarView buttons: [1]).toThrow()


describe 'acorn.player.controls.ControlView', ->
  ControlView = acorn.player.controls.ControlView

  describeView = athena.lib.util.test.describeView
  describeView ControlView, athena.lib.View

  it 'should be part of acorn.player.controls', ->
    expect(ControlView).toBeDefined()

  it 'should have factory constructor `withId`', ->
    expect(typeof ControlView.withId).toBe 'function'
