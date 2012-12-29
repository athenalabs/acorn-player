goog.provide 'acorn.util.test'

goog.require 'acorn.util'



acorn.util.test =


  # call pattern: Module [, modelOptions] [, tests]
  describeShellModule: (Module, modelOptions, tests) =>

    # cycle arguments if necessary
    unless athena.lib.util.isStrictObject modelOptions
      tests = modelOptions
      modelOptions = {}

    derives = athena.lib.util.derives
    Shell = acorn.shells.Shell

    acorn.util.assert Shell, 'goog.require \'acorn.shells.Shell\' before ' +
      'calling acorn.util.test.describeShellModule'

    describeView = athena.lib.util.test.describeView

    isOrDerives = (Subclass, Superclass) =>
      Subclass == Superclass or derives Subclass, Superclass

    describe "#{Module.id} shell module", ->

      it 'should contain required properties', ->
        requiredProperties = [ 'id', 'title', 'description', 'icon' ]
        _.each requiredProperties, (property) ->
          expect(Module[property]).toBeDefined()
          expect(_.isString Module[property]).toBe true

      it 'should contain required Model and View classes', ->
        requiredClasses = [ 'Model', 'MediaView', 'RemixView' ]
        _.each requiredClasses, (property) ->
          expect(Module[property]).toBeDefined()
          expect(_.isFunction Module[property]).toBe true

      viewOptions = -> model: new Module.Model modelOptions

      describe "#{Module.id}.Model", ->
        Model = Module.Model

        it 'should derive from athena.lib.Model', ->
          expect(derives Model, athena.lib.Model).toBe true

        it 'should derive from (or be) Shell.Model', ->
          expect(isOrDerives Model, Shell.Model).toBe true

        it 'should correctly assign attributes', ->
          m = new Model _.extend modelOptions, {a: 1, b:2}
          expect(m.get 'a').toBe 1
          expect(m.get 'b').toBe 2

        it 'should correctly support setting of attributes', ->
          m = new Model _.extend modelOptions, {a: 1, b:2}
          m.set 'a', 2
          m.set 'b', 3
          expect(m.get 'a').toBe 2
          expect(m.get 'b').toBe 3

        it 'should throw an exception on save/sync', ->
          m = new Model _.extend modelOptions, {a: 1, b:2}
          expect(m.save).toThrow()
          expect(m.sync).toThrow()

        it 'should be clonable (with deep-copies)', ->
          deep = {'a': 5}
          m = new Model _.extend modelOptions, {shellid:'Shell', a: b: c: deep}
          expect(m.clone().attributes.a.b.c).toEqual deep
          expect(m.clone().attributes.a.b.c).not.toBe deep

          # ensure the same thing breaks on Backbone's non-deep copy
          b = new Backbone.Model {shellid:'Shell', a: b: c: deep}
          expect(b.clone().attributes.a.b.c).toEqual deep
          expect(b.clone().attributes.a.b.c).toBe deep

        it 'should have a toJSONString function', ->
          expect(typeof Model::toJSONString).toBe 'function'
          m = new Model _.extend modelOptions,
              {shellid:'Shell', a: b: c: {'a': 5}}
          s = m.toJSONString()
          expect(JSON.stringify m.attributes).toEqual s




      describeView Module.MediaView, athena.lib.View, viewOptions(), ->

        MediaView = Module.MediaView

        it 'should derive from athena.lib.View', ->
          expect(derives MediaView, athena.lib.View).toBe true

        it 'should derive from (or be) Shell.MediaView', ->
          expect(isOrDerives MediaView, Shell.MediaView).toBe true

        it 'should require `model` parameter', ->
          throwOptions = viewOptions()
          delete throwOptions.model
          expect(-> new MediaView viewOptions()).not.toThrow()
          expect(-> new MediaView throwOptions).toThrow()

      describeView Module.RemixView, athena.lib.View, viewOptions(), ->

        RemixView = Module.RemixView

        it 'should derive from athena.lib.View', ->
          expect(derives RemixView, athena.lib.View).toBe true

        it 'should derive from (or be) Shell.RemixView', ->
          expect(isOrDerives RemixView, Shell.RemixView).toBe true

        it 'should require `model` parameter', ->
          throwOptions = viewOptions()
          delete throwOptions.model
          expect(-> new RemixView viewOptions()).not.toThrow()
          expect(-> new RemixView throwOptions).toThrow()

      tests?()

