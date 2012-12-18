goog.provide 'acorn.specs.shells.CollectionShell'

goog.require 'acorn.shells.CollectionShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.CollectionShell', ->
  derives = athena.lib.util.derives
  EventSpy = athena.lib.util.test.EventSpy

  Shell = acorn.shells.Shell
  CollectionShell = acorn.shells.CollectionShell

  it 'should be part of acorn.shells', ->
    expect(CollectionShell).toBeDefined()

  acorn.util.test.describeShellModule CollectionShell

  describe 'CollectionShell.Model', ->
    Model = CollectionShell.Model

    describe 'Model::shells', ->
      it 'should be a function', ->
        expect(typeof Model::shells).toBe 'function'

      it 'should retrieve internal state correctly', ->
        shells = [{shellid: Shell.id}, {shellid: Shell.id}]
        m = new Model shellid: CollectionShell.id, shells: shells
        expect(m.shells()).toBe shells
        expect(m.attributes.shells).toBe shells

      it 'should return empty array when unitialized', ->
        m = new Model shellid: CollectionShell.id
        expect(m.attributes.shells).not.toBeDefined()
        expect(m.shells()).toEqual []

      it 'should modify internal state correctly', ->
        shells = []
        m = new Model shellid: CollectionShell.id, shells: shells
        expect(m.shells()).toBe shells
        expect(m.attributes.shells).toBe shells

        shells = [{shellid: Shell.id}, {shellid: Shell.id}]
        expect(m.shells shells).toBe shells
        expect(m.shells()).toBe shells
        expect(m.attributes.shells).toBe shells

      it 'should trigger change events correctly', ->
        m = new Model shellid: CollectionShell.id, shells: []
        spy1 = new EventSpy m, 'change'
        spy2 = new EventSpy m, 'change:shells'

        m.shells [{shellid: Shell.id}, {shellid: Shell.id}]
        expect(spy1.triggered).toBe true
        expect(spy2.triggered).toBe true

    describe 'Model::addShell', ->
      it 'should be a function', ->
        expect(typeof Model::addShell).toBe 'function'

      it 'should return @', ->
        m = new Model shellid: CollectionShell.id, shells: []
        shell = {shellid: Shell.id}
        expect(m.addShell shell).toBe m

      it 'should add shells by value (object)', ->
        m = new Model shellid: CollectionShell.id, shells: []
        expect(m.shells()).toEqual []
        expect(m.attributes.shells).toEqual []

        shell = acorn.shellWithData(shellid: Shell.id).attributes
        m.addShell shell
        expect(m.shells()).toEqual [shell]
        expect(m.attributes.shells).toEqual [shell]

      it 'should add shells by value (data)', ->
        m = new Model shellid: CollectionShell.id, shells: []
        expect(m.shells()).toEqual []
        expect(m.attributes.shells).toEqual []

        shell = acorn.shellWithData shellid: Shell.id
        m.addShell shell.attributes
        expect(m.shells()).toEqual [shell.attributes]
        expect(m.attributes.shells).toEqual [shell.attributes]

      it 'should add shells with index', ->
        shells = [{shellid: CollectionShell.id}, {shellid: TextShell.id}]
        m = new Model shellid: CollectionShell.id, shells: _.clone shells
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

        shell = {shellid: Shell.id}
        shells = [shells[0], shell, shells[1]]
        m.addShell shell, 1
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

      it 'should modify internal state correctly', ->
        m = new Model shellid: CollectionShell.id, shells: []
        expect(m.shells()).toEqual []
        expect(m.attributes.shells).toEqual []

        shell = {shellid: Shell.id}
        m.addShell shell
        expect(m.shells()).toEqual [shell]
        expect(m.attributes.shells).toEqual [shell]

      it 'should trigger change events correctly', ->
        m = new Model shellid: CollectionShell.id, shells: []
        spy1 = new EventSpy m, 'change'
        spy2 = new EventSpy m, 'change:shells'

        m.addShell {shellid: Shell.id}
        expect(spy1.triggered).toBe true
        expect(spy2.triggered).toBe true

    describe 'Model::removeShell', ->
      it 'should be a function', ->
        expect(typeof Model::removeShell).toBe 'function'

      it 'should return @', ->
        shell = {shellid: Shell.id}
        m = new Model shellid: CollectionShell.id, shells: [shell]
        expect(m.removeShell shell).toBe m

      it 'should remove shells by value (shell)', ->
        shell = Model.withData shellid: Shell.id
        shells = [
          Model.withData(shellid: TextShell.id).attributes
          shell.attributes
          Model.withData(shellid: CollectionShell.id).attributes
        ]
        m = new Model shellid: CollectionShell.id, shells: shells
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

        shells = [shells[0], shells[2]]
        m.removeShell shell
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

      it 'should remove shells by value (data)', ->
        shell = Model.withData shellid: Shell.id
        shells = [
          Model.withData(shellid: TextShell.id).attributes
          shell.attributes
          shell.attributes
        ]
        m = new Model shellid: CollectionShell.id, shells: shells
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

        shells = [shells[0]]
        m.removeShell shell.attributes
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

      it 'should remove shells by index', ->
        shell = {shellid: Shell.id}
        shells = [
          Model.withData(shellid: TextShell.id).attributes
          shell.attributes
          Model.withData(shellid: Shell.id).attributes
        ]
        m = new Model shellid: CollectionShell.id, shells: shells
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

        shells = [shells[0], shells[2]]
        m.removeShell 1
        expect(m.shells()).toEqual shells
        expect(m.attributes.shells).toEqual shells

      it 'should trigger change events correctly', ->
        shells = [{shellid: Shell.id}]
        m = new Model shellid: CollectionShell.id, shells: shells
        spy1 = new EventSpy m, 'change'
        spy2 = new EventSpy m, 'change:shells'

        m.removeShell 0
        expect(spy1.triggered).toBe true
        expect(spy2.triggered).toBe true

      it 'should error out if passed neither a shell or integer', ->
        m = new Model shellid: CollectionShell.id, shells: []
        expect(-> m.removeShell 1.2423).toThrow()
        expect(-> m.removeShell 'some string').toThrow()
        expect(-> m.removeShell {some: 'object'}).toThrow()
        expect(-> m.removeShell [1, 2, 3]).toThrow()
