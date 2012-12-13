goog.provide 'acorn.specs.player.Player'

goog.require 'acorn.Model'
goog.require 'acorn.shells.Shell'
goog.require 'acorn.player.Player'
goog.require 'acorn.config'

describe 'acorn.player.Player', ->
  Player = acorn.player.Player

  # sample acorn to test with
  acornModel = new acorn.Model
    shell:
      id: 'acorn.Shell'
      thumbnail: acorn.config.img.acorn

  it 'should be part of acorn.player', ->
    expect(acorn.player.Player).toBeDefined()

  it 'should mixin Backbone.Events', ->
    _.each Backbone.Events, (val, key) ->
      expect(Player::[key]).toBeDefined()
      expect(typeof Player::[key]).toBe(typeof val)

  it 'should be constructed with an acornModel', ->
    p = new Player acornModel: acornModel
    expect(p.acornModel).toBe acornModel

  it 'should have a shellModel property that corresponds to the acorn', ->
    p = new Player acornModel: acornModel
    expect(p.shellModel.toJSON()).toEqual acornModel.shellData()

  describe 'acorn.player.Player.view property', ->

    it 'should be a property of type PlayerView', ->
      p = new Player acornModel: acornModel
      expect(p.view instanceof acorn.player.PlayerView).toBe true

    it 'should have the Player as eventhub', ->
      p = new Player acornModel: acornModel
      expect(p.view.eventhub).toBe p

    it 'should match the Player\'s models', ->
      p = new Player acornModel: acornModel
      expect(p.view.model.acornModel).toBe p.acornModel
      expect(p.view.model.shellModel).toBe p.shellModel
