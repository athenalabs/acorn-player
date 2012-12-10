goog.provide 'acorn.specs.player.Player'

goog.require 'acorn.player.Player'

describe 'acorn.player.Player', ->
  Player = acorn.player.Player

  it 'should be part of acorn.player', ->
    expect(acorn.player.Player).toBeDefined()

  it 'should mixin Backbone.Events', ->
    _.each Backbone.Events, (val, key) ->
      expect(Player[key]).toBeDefined()
      expect(typeof Player[key]).toBe(typeof val)

