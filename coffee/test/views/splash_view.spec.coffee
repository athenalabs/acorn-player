goog.provide 'acorn.specs.player.SplashView'

goog.require 'acorn.player.SplashView'

describe 'acorn.player.SplashView', ->
  SplashView = acorn.player.SplashView

  it 'should be part of acorn.player', ->
    expect(acorn.player.SplashView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives SplashView, athena.lib.View).toBe true
