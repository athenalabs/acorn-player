goog.provide 'acorn.player.PlayerView.spec'

goog.require 'acorn.player.PlayerView'

describe 'acorn.player.PlayerView', ->
  PlayerView = acorn.player.PlayerView
  derives = athena.lib.util.derives

  it 'should be part of acorn.player', ->
    expect(acorn.player.PlayerView).toBeDefined()

  it 'should derive from athena.lib.ContainerView', ->
    expect(derives PlayerView, athena.lib.ContainerView).toBe true
