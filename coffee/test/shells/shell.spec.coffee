goog.provide 'acorn.specs.shells.Shell'

goog.require 'acorn.shells.Shell'


describe 'acorn.shells.Shell', ->
  Shell = acorn.shells.Shell

  it 'should be part of acorn.shells', ->
    expect(Shell).toBeDefined()

  it 'should contain required properties', ->
    required_properties = [ 'id', 'title', 'description' ]
    _.each required_properties, (property) ->
      expect(Shell[property]).toBeDefined()
      expect(_.isString Shell[property]).toBe true
  
  it 'should contain required Model and View classes', ->
    required_classes = [ 'Model', 'ContentView', 'RemixView' ]
    _.each required_classes, (property) ->
      expect(Shell[property]).toBeDefined()
      expect(_.isFunction Shell[property]).toBe true

  describe 'acorn.shells.Shell.Model class', ->

    model_instance = new Shell.Model { a: 1, b: 2 }

    it 'should derive from Backbone.Model', ->
      expect(athena.lib.util.derives Shell.Model, Backbone.Model).toBe true

    it 'should correctly assign attributes', ->
      expect(model_instance.get 'a').toBe 1
      expect(model_instance.get 'b').toBe 2

    it 'should correctly support setting of attributes', ->
      model_instance.set 'a', 2
      model_instance.set 'b', 3
      expect(model_instance.get 'a').toBe 2
      expect(model_instance.get 'b').toBe 3

    it 'should throw an exception on save/sync', ->
      expect(model_instance.save).toThrow()
      expect(model_instance.sync).toThrow()

    it 'should correctly support clone', ->
      model_clone = model_instance.clone()
      model_clone.set 'a', 42
      expect(model_instance.get 'a').toBe 2
      expect(model_clone.get 'a').toBe 42

  describe 'acorn.shells.Shell.Model factory constructors', ->

    it 'should correctly construct a model from data', ->
      model_instance = Shell.Model.withData { id: 'acorn.Shell' }
      expect(model_instance).toBeDefined()
      expect(model_instance.get 'id').toBe 'acorn.Shell'

    it 'should throw an error on attempts to construct unregistered shells', ->
      fn = -> Shell.Model.withData { id: 'foobar' }
      expect(fn).toThrow()

  describe 'acorn.shells.Shell.ContentView', ->
    it 'should derive from athena.lib.View', ->
      expect(athena.lib.util.derives Shell.ContentView,
             athena.lib.View).toBe true

  describe 'acorn.shells.Shell.RemixView', ->
    it 'should derive from athena.lib.View', ->
      expect(athena.lib.util.derives Shell.RemixView,
             athena.lib.View).toBe true
