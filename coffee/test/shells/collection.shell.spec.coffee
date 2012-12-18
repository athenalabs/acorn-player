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
