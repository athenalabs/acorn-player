goog.provide 'acorn.specs.shells.Shell'

goog.require 'acorn.shells.Shell'
goog.require 'acorn.util.test'

describe 'acorn.shells.Shell', ->
  Shell = acorn.shells.Shell

  it 'should be part of acorn.shells', ->
    expect(Shell).toBeDefined()

  acorn.util.test.describeShellModule Shell, ->

    describe 'acorn.shells.Shell.Model factory constructors', ->

      it 'should correctly construct a model from data', ->
        modelInstance = Shell.Model.withData { shellid: 'acorn.Shell' }
        expect(modelInstance).toBeDefined()
        expect(modelInstance.get 'shellid').toBe 'acorn.Shell'

      it 'should throw error on attempts to construct unregistered shells', ->
        fn = -> Shell.Model.withData { shellid: 'foobar' }
        expect(fn).toThrow()
