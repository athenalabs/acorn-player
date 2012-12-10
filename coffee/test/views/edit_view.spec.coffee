goog.provide 'acorn.player.EditView.spec'

goog.require 'acorn.player.EditView'

describe 'acorn.player.EditView', ->
  EditView = acorn.player.EditView

  it 'should be part of acorn.player', ->
    expect(acorn.player.EditView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives EditView, athena.lib.View).toBe true
