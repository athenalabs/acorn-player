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
      shellid: 'acorn.Shell'
      title: 'Awesome Shell'
      description: 'The best shell this side of the Kuiper Belt'
      sources: ['me']
      thumbnail: acorn.config.img.acorn

  it 'should be part of acorn.player', ->
    expect(Player).toBeDefined()

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

  describe 'model verification', ->

    it 'should fail to construct if acornModel was not passed in', ->
      expect(-> new Player).toThrow()

    it 'should fail to construct if model type is incorrect', ->
      expect(-> new Player acornModel: {bad: value}).toThrow()
      expect(-> new Player acornModel: new athena.lib.Model).toThrow()

    it 'should succeed to construct if model type is correct', ->
      expect(acornModel instanceof acorn.Model).toBe true
      expect(-> new Player acornModel: acornModel).not.toThrow()

  describe 'acorn.player.Player.view property', ->

    it 'should be a property of type PlayerView', ->
      p = new Player acornModel: acornModel
      expect(p.view instanceof acorn.player.PlayerView).toBe true

    it 'should have the Player as eventhub', ->
      p = new Player acornModel: acornModel
      expect(p.view.eventhub).toBe p

    it 'should match the Player\'s models', ->
      p = new Player acornModel: acornModel
      expect(p.view.model).toBe p.acornModel


  it 'should force editable if acornModel.isNew()', ->
    test = (options, bool) ->
      expect(new Player(options).editable()).toBe bool

    test({acornModel: acornModel}, true)
    test({acornModel: acornModel, editable: false}, true)
    test({acornModel: acornModel, editable: true}, true)

    acornModel2 = acornModel.clone()
    acornModel2.acornid('foo')
    expect(acornModel2.isNew()).toBe false
    test({acornModel: acornModel2}, false)
    test({acornModel: acornModel2, editable: false}, false)
    test({acornModel: acornModel2, editable: true}, true)


  it 'should forward editable option to playerView', ->
    acornModel2 = acornModel.clone()
    acornModel2.acornid('foo')
    expect(acornModel2.isNew()).toBe false

    p = new Player acornModel: acornModel2
    expect(p.view.editable()).toBeFalsy()

    p = new Player acornModel: acornModel2, editable: false
    expect(p.view.editable()).toBeFalsy()

    p = new Player acornModel: acornModel2, editable: true
    expect(p.view.editable()).toBeTruthy()

