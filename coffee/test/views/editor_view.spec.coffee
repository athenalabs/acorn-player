goog.provide 'acorn.specs.player.EditorView'

goog.require 'acorn.player.EditorView'

describe 'acorn.player.EditorView', ->
  EditorView = acorn.player.EditorView

  it 'should be part of acorn.player', ->
    expect(acorn.player.EditorView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives EditorView, athena.lib.View).toBe true
