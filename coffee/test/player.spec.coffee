goog.provide 'acorn.specs.player.Player'

goog.require 'acorn.Model'
goog.require 'acorn.shells.Shell'
goog.require 'acorn.player.Player'
goog.require 'acorn.config'

describe 'acorn.player.Player', ->
  Player = acorn.player.Player

  # sample acorn to test with
  model = new acorn.Model
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

  it 'should be constructed with a model', ->
    p = new Player model: model
    expect(p.model).toBe model

  it 'should be constructed with a model (acornModel -- backwards compat.)', ->
    p = new Player acornModel: model
    expect(p.model).toBe model
    expect(p.acornModel).toBe model


  describe 'model verification', ->

    it 'should fail to construct if model was not passed in', ->
      expect(-> new Player).toThrow()

    it 'should fail to construct if model type is incorrect', ->
      expect(-> new Player model: {bad: value}).toThrow()
      expect(-> new Player model: new athena.lib.Model).toThrow()

    it 'should succeed to construct if model type is correct', ->
      expect(model instanceof acorn.Model).toBe true
      expect(-> new Player model: model).not.toThrow()

  describe 'acorn.player.Player.view property', ->

    it 'should be a property of type PlayerView', ->
      p = new Player model: model
      expect(p.view instanceof acorn.player.PlayerView).toBe true

    it 'should have the Player as eventhub', ->
      p = new Player model: model
      expect(p.view.eventhub).toBe p

    it 'should match the Player\'s model', ->
      p = new Player model: model
      expect(p.view.model).toBe p.model


  it 'should force editable if model.isNew()', ->
    test = (options, bool) ->
      expect(new Player(options).editable()).toBe bool

    test({model: model}, true)
    test({model: model, editable: false}, true)
    test({model: model, editable: true}, true)

    model2 = model.clone()
    model2.acornid('foo')
    expect(model2.isNew()).toBe false
    test({model: model2}, false)
    test({model: model2, editable: false}, false)
    test({model: model2, editable: true}, true)


  it 'should forward editable option to playerView', ->
    model2 = model.clone()
    model2.acornid('foo')
    expect(model2.isNew()).toBe false

    p = new Player model: model2
    expect(p.view.editable()).toBeFalsy()

    p = new Player model: model2, editable: false
    expect(p.view.editable()).toBeFalsy()

    p = new Player model: model2, editable: true
    expect(p.view.editable()).toBeTruthy()

