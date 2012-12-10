goog.provide 'acorn.player.ContentView.spec'

goog.require 'acorn.player.ContentView'

describe 'acorn.player.ContentView', ->
  ContentView = acorn.player.ContentView

  it 'should be part of acorn.player', ->
    expect(acorn.player.ContentView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives ContentView, athena.lib.View).toBe true
