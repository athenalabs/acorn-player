`import "util"`


test = acorn.util.test = {}


# call pattern: Module [, modelOptions] [, tests]
test.describeShellModule = (Module, modelOptions, tests) =>

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

      acorn.util.test.describeMediaInterface Module.MediaView, viewOptions()


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



test.describeMediaInterface = (Cls, options, tests) ->

  # cycle arguments if necessary
  unless athena.lib.util.isStrictObject options
    tests = options
    options = {}

  test = athena.lib.util.test
  MediaInterface = acorn.MediaInterface

  capitalize = (s) ->
    s.replace /^[a-z]/i, (m) -> m.toUpperCase()

  describe "#{Cls.name} - media interface", ->

    describe 'should implement media interface', ->
      _.each MediaInterface.prototype, (val, key) ->
        type = typeof val
        it "#{Cls.name}::#{key} should exist (#{type})", ->
          expect(Cls::[key]).toBeDefined()
          expect(typeof Cls::[key]).toBe type


    describeStateChange = (name) ->
      Name = capitalize(name)
      describe "#{Cls.name} mediaState #{name}", ->

        it 'should be a valid state', ->
          expect(typeof Cls::mediaStates[name]).toBeDefined()


        it "should trigger Will#{Name}, #{Name}, change, then Did#{Name}", ->
          flag = 0
          iface = new Cls _.extend options, playOnReady: false
          iface.render?()

          # later states require init and ready to have happened
          if name isnt 'init'
            iface.setMediaState 'init'
            if name isnt 'ready'
              iface.setMediaState 'ready'


          iface.on "Media:Will#{Name}", ->
            if name isnt 'init'
              expect(iface.mediaState()).not.toBe name
            expect(flag).toBe 0
            flag = 1

          iface.on "Media:#{Name}", ->
            if name isnt 'init'
              expect(iface.mediaState()).not.toBe name
            expect(flag).toBe 1
            flag = 2

          iface.on "Media:Did#{Name}", ->
            expect(iface.mediaState()).toBe name
            expect(flag).toBe 2
            flag = 3

          expect(flag).toBe(0)
          iface.setMediaState(name)
          expect(flag).toBe(3)

          iface.off "Media:Will#{Name}"
          iface.off "Media:#{Name}"
          iface.off "Media:Did#{Name}"

          iface.pause()
          iface.destroy?()


        it "should call defined on(Will,,Did)Media#{Name} in order", ->
          flag = 0
          iface = new Cls _.extend options, playOnReady: false
          iface.render?()

          # later states require init and ready to have happened
          if name isnt 'init'
            iface.setMediaState 'init'
            if name isnt 'ready'
              iface.setMediaState 'ready'


          iface["onMediaWill#{Name}"] = =>
            if name isnt 'init'
              expect(iface.mediaState()).not.toBe name
            expect(flag).toBe 0
            flag = 1

          iface["onMedia#{Name}"] = =>
            if name isnt 'init'
              expect(iface.mediaState()).not.toBe name
            expect(flag).toBe 1
            flag = 2

          iface["onMediaDid#{Name}"] = =>
            expect(iface.mediaState()).toBe name
            expect(flag).toBe 2
            flag = 3

          expect(flag).toBe(0)
          iface.setMediaState(name)
          expect(flag).toBe(3)

          iface["onMediaWill#{Name}"] = =>
          iface["onMedia#{Name}"] = =>
          iface["onMediaDid#{Name}"] = =>
          iface.pause()
          iface.destroy?()


        it "#{Cls.name}::isInState(#{name}) should return true", ->
          iface = new Cls _.extend options, playOnReady: false
          if name isnt 'init' and name isnt 'ready'
            expect(iface.isInState name).not.toBe true
          iface.setMediaState(name)
          expect(iface.isInState name).toBe true

          iface.pause()
          iface.destroy?()


    describeStateChange 'init'
    describeStateChange 'ready'
    describeStateChange 'play'
    describeStateChange 'pause'
    describeStateChange 'end'


    describeFunction = (name, tests) ->
      describe "#{Cls.name}::#{name}", ->
        it 'should be a function', ->
          expect(typeof Cls::[name]).toBe 'function'

        tests?()


    describeFunction 'isReady', ->
      it 'should call isInState `ready` ', ->
        iface = new Cls options
        spyOn iface, 'isInState'
        iface.isReady()
        expect(iface.isInState).toHaveBeenCalledWith 'ready'


    describeFunction 'isPlaying', ->
      it 'should call isInState `play` ', ->
        iface = new Cls options
        spyOn iface, 'isInState'
        iface.isPlaying()
        expect(iface.isInState).toHaveBeenCalledWith 'play'


    describeFunction 'isPaused', ->
      it 'should call isInState `pause` ', ->
        iface = new Cls options
        spyOn iface, 'isInState'
        iface.isPaused()
        expect(iface.isInState).toHaveBeenCalledWith 'pause'


    describeFunction 'ended', ->
      it 'should call isInState `end` ', ->
        iface = new Cls options
        spyOn iface, 'isInState'
        iface.ended()
        expect(iface.isInState).toHaveBeenCalledWith 'end'


    describeFunction 'play', ->
      it 'should trigger setMediaState `play`', ->
        iface = new Cls options
        iface.setMediaState 'init'
        iface.setMediaState 'ready'
        spyOn iface, 'setMediaState'
        iface.play()
        expect(iface.setMediaState).toHaveBeenCalledWith 'play'


    describeFunction 'pause', ->
      it 'should trigger setMediaState `pause`', ->
        iface = new Cls options
        iface.setMediaState 'init'
        iface.setMediaState 'ready'
        iface.setMediaState 'play'
        spyOn iface, 'setMediaState'
        iface.pause()
        expect(iface.setMediaState).toHaveBeenCalledWith 'pause'


    describeFunction 'seek'
    describeFunction 'seekOffset'
    describeFunction 'seek'
    describeFunction 'duration'
    describeFunction 'volume'
    describeFunction 'setVolume'
    describeFunction 'width'
    describeFunction 'height'
    describeFunction 'setWidth'
    describeFunction 'setHeight'
    describeFunction 'objectFit'
    describeFunction 'setObjectFit'


  tests?()
