goog.provide 'acorn.util.test'

goog.require 'acorn.util'

acorn.util.test.describeShellModule = (Module, tests) =>
  derives = athena.lib.util.derives
  Shell = acorn.shells.Shell

  isOrDerives = (Subclass, Superclass) =>
    Subclass == Superclass or derives Subclass, Superclass

  describe "#{Module.id} shell module", ->

    it 'should contain required properties', ->
      requiredProperties = [ 'id', 'title', 'description' ]
      _.each requiredProperties, (property) ->
        expect(Module[property]).toBeDefined()
        expect(_.isString Module[property]).toBe true

    it 'should contain required Model and View classes', ->
      requiredClasses = [ 'Model', 'ContentView', 'RemixView' ]
      _.each requiredClasses, (property) ->
        expect(Module[property]).toBeDefined()
        expect(_.isFunction Module[property]).toBe true

    describe "#{Module.id}.Model", ->
      Model = Module.Model

      it 'should derive from Backbone.Model', ->
        expect(derives Model, Backbone.Model).toBe true

      it 'should derive from (or be) Shell.Model', ->
        expect(isOrDerives Model, Shell.Model).toBe true

      it 'should correctly assign attributes', ->
        m = new Model a: 1, b:2
        expect(m.get 'a').toBe 1
        expect(m.get 'b').toBe 2

      it 'should correctly support setting of attributes', ->
        m = new Model a: 1, b:2
        m.set 'a', 2
        m.set 'b', 3
        expect(m.get 'a').toBe 2
        expect(m.get 'b').toBe 3

      it 'should throw an exception on save/sync', ->
        m = new Model a: 1, b:2
        expect(m.save).toThrow()
        expect(m.sync).toThrow()

      it 'should be clonable (with deep-copies)', ->
        deep = {'a': 5}
        m = new Model {shellid:'Shell', a: b: c: deep}
        expect(m.clone().attributes.a.b.c).toEqual deep
        expect(m.clone().attributes.a.b.c).not.toBe deep

        # ensure the same thing breaks on Backbone's non-deep copy
        b = new Backbone.Model {shellid:'Shell', a: b: c: deep}
        expect(b.clone().attributes.a.b.c).toEqual deep
        expect(b.clone().attributes.a.b.c).toBe deep

      it 'should have a toJSONString function', ->
        expect(typeof Model::toJSONString).toBe 'function'
        m = new Model {shellid:'Shell', a: b: c: {'a': 5}}
        s = m.toJSONString()
        expect(JSON.stringify m.attributes).toEqual s

    describe "#{Module.id}.ContentView", ->
      ContentView = Module.ContentView

      options =
        model: new Module.Model

      it 'should derive from athena.lib.View', ->
        expect(derives ContentView, athena.lib.View).toBe true

      it 'should derive from (or be) Shell.ContentView', ->
        expect(isOrDerives ContentView, Shell.ContentView).toBe true

      it 'should require `model` parameter', ->
        throwOptions = _.clone options
        delete throwOptions.model
        expect(-> new ContentView options).not.toThrow()
        expect(-> new ContentView throwOptions).toThrow()

    describe "#{Module.id}.RemixView", ->
      RemixView = Module.RemixView

      options =
        model: new Module.Model

      it 'should derive from athena.lib.View', ->
        expect(derives RemixView, athena.lib.View).toBe true

      it 'should derive from (or be) Shell.RemixView', ->
        expect(isOrDerives RemixView, Shell.RemixView).toBe true

      it 'should require `model` parameter', ->
        throwOptions = _.clone options
        delete throwOptions.model
        expect(-> new RemixView options).not.toThrow()
        expect(-> new RemixView throwOptions).toThrow()

    tests?()

