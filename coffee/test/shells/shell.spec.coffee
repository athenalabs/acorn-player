goog.provide 'acorn.specs.shells.Shell'

goog.require 'acorn.shells.Shell'


describe 'acorn.shells.Shell', ->
  Shell = acorn.shells.Shell

  it 'should be part of acorn.shells', ->
    expect(Shell).toBeDefined()

  it 'should contain required properties', ->
    requiredProperties = [ 'id', 'title', 'description' ]
    _.each requiredProperties, (property) ->
      expect(Shell[property]).toBeDefined()
      expect(_.isString Shell[property]).toBe true
  
  it 'should contain required Model and View classes', ->
    requiredClasses = [ 'Model', 'ContentView', 'RemixView' ]
    _.each requiredClasses, (property) ->
      expect(Shell[property]).toBeDefined()
      expect(_.isFunction Shell[property]).toBe true

  describe 'acorn.shells.Shell.Model class', ->

    modelInstance = new Shell.Model { a: 1, b: 2 }

    it 'should derive from Backbone.Model', ->
      expect(athena.lib.util.derives Shell.Model, Backbone.Model).toBe true

    it 'should correctly assign attributes', ->
      expect(modelInstance.get 'a').toBe 1
      expect(modelInstance.get 'b').toBe 2

    it 'should correctly support setting of attributes', ->
      modelInstance.set 'a', 2
      modelInstance.set 'b', 3
      expect(modelInstance.get 'a').toBe 2
      expect(modelInstance.get 'b').toBe 3

    it 'should throw an exception on save/sync', ->
      expect(modelInstance.save).toThrow()
      expect(modelInstance.sync).toThrow()

    it 'should correctly support clone', ->
      modelClone = modelInstance.clone()
      modelClone.set 'a', 42
      expect(modelInstance.get 'a').toBe 2
      expect(modelClone.get 'a').toBe 42

  describe 'acorn.shells.Shell.Model factory constructors', ->

    it 'should correctly construct a model from data', ->
      modelInstance = Shell.Model.withData { shellid: 'acorn.Shell' }
      expect(modelInstance).toBeDefined()
      expect(modelInstance.get 'shellid').toBe 'acorn.Shell'

    it 'should throw an error on attempts to construct unregistered shells', ->
      fn = -> Shell.Model.withData { shellid: 'foobar' }
      expect(fn).toThrow()

  describe 'acorn.shells.Shell.ContentView', ->
    it 'should derive from athena.lib.View', ->
      expect(athena.lib.util.derives Shell.ContentView,
             athena.lib.View).toBe true

  describe 'acorn.shells.Shell.RemixView', ->
    it 'should derive from athena.lib.View', ->
      expect(athena.lib.util.derives Shell.RemixView,
             athena.lib.View).toBe true
