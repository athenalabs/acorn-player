goog.provide 'acorn.specs.shells.Registry'

goog.require 'acorn.shells.Registry'

throwsExceptionWithString = athena.lib.util.test.throwsExceptionWithString

describe 'acorn.shells.Registry', ->
  Registry = acorn.shells.Registry

  # -- helpers --

  shellModule =
    id: 'ApertureScience.GladOS'
    title: 'Portal into GladOS\'s internal psychological state'
    description: 'Um... self-describing'
    icon: 'icon-play'
    Model: =>
    MediaView: =>
    RemixView: =>

  register_fn = -> Registry.registerModule shellModule

  modulesClone = null

  # -- setup and teardown --

  beforeEach -> modulesClone = _.clone Registry.modules
  afterEach -> Registry.modules = modulesClone



  it 'should be a part of acorn.shells', ->
    expect(Registry).toBeDefined()

  describe 'Registry.modules', ->
    it 'should be an object', ->
      expect(_.isObject Registry.modules).toBe true

  describe 'Registry.moduleWithId', ->

    it 'should be a function', ->
      expect(_.isFunction Registry.moduleWithId).toBe true

    it 'should be aliased to acorn.shellModuleWithId', ->
      expect(acorn.shellModuleWithId).toBe Registry.moduleWithId

    it 'should return registered shell modules', ->
      register_fn()
      expect(Registry.moduleWithId 'ApertureScience.GladOS').toBe shellModule

    it 'should throw error for unregistered shell modules', ->
      expect(Registry.moduleWithId, 'ApertureScience.GladOS').toThrow()


  describe 'Registry.collectionModules', ->

    it 'should return all modules that derive from CollectionShell', ->
      modules = Registry.modules
      collections = Registry.collectionModules()
      for Shell in modules
        derives = Shell.isOrDerives CollectionShell
        expect(_.contains collections, Shell).toBe derives


  describe 'Registry.registerModule', ->

    # -- helpers --

    assertObjectSize = (object, size) => expect(_.keys(object).length).toBe size
    unregisterAllShells = => Registry.modules = {}

    # -- test cases --

    it 'should be a function', ->
      expect(_.isFunction Registry.registerModule).toBe true

    it 'should be aliased to acorn.registerShellModules', ->
      expect(acorn.registerShellModule).toBe Registry.registerModule

    it 'should properly register valid shell modules', ->
      expect(register_fn).not.toThrow()
      expect(shellModule).toBe Registry.modules['ApertureScience.GladOS']

    it 'should correctly create backpointers to the module', ->
      expect(shellModule.Model.module).toBe shellModule
      expect(shellModule.MediaView.module).toBe shellModule
      expect(shellModule.RemixView.module).toBe shellModule

    describe 'Registry.registerModule error handling', ->
      it 'should throw error if shell is already registered', ->
        unregisterAllShells()
        register_fn()
        expect(register_fn).toThrow()
        assertObjectSize Registry.modules, 1

      it 'should throw error if missing a required property', ->
        unregisterAllShells()

        requiredProperties = [ 'id', 'title', 'icon', 'Model' ]
        _.each requiredProperties, (property) ->
          moduleClone = _.clone shellModule

          # remove property from module
          delete moduleClone[property]

          # ensure validation throws the right error
          ret = throwsExceptionWithString("`#{property}` is missing",
            Registry.registerModule, moduleClone)
          expect(ret).toBe true

          # ensure the Registry wasn't modified
          assertObjectSize Registry.modules, 0

      it 'should throw error if properties are of incorrect types', ->
        unregisterAllShells()

        stringProperties = [ 'id', 'title', 'icon' ]
        _.each stringProperties, (property) ->
          moduleClone = _.clone shellModule

          # change type of property
          moduleClone[property] = 42 # type: "number"

          # ensure vaidation throws the right error
          ret = throwsExceptionWithString("Type error: `#{property}`",
            Registry.registerModule, moduleClone)
          expect(ret).toBe true
          assertObjectSize Registry.modules, 0

        functionProperties = [ 'Model', 'MediaView', 'RemixView' ]
        _.each functionProperties, (property) ->
          moduleClone = _.clone shellModule

          # change type of property
          moduleClone[property] = 42

          # ensure vaidation throws the right error
          ret = throwsExceptionWithString("Type error: `#{property}`",
            Registry.registerModule, moduleClone)
          expect(ret).toBe true
          assertObjectSize Registry.modules, 0

    describe 'Registry.registerModule optional properties', ->
      it 'should be correctly set on the module', ->
        optionalProperties = [ 'description', 'MediaView', 'RemixView' ]
        _.each optionalProperties, (property) ->
          moduleClone = _.clone shellModule

          # remove optional property
          delete moduleClone[property]

          # register module
          Registry.registerModule moduleClone

          # ensure registration has set optional property to Shell's default
          expect(typeof moduleClone[property]).toBe typeof Shell[property]

          # unregister all shells
          unregisterAllShells()

