goog.provide 'acorn.specs.shells.LinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.LinkShell', ->
  LinkShell = acorn.shells.LinkShell

  it 'should be part of acorn.shells', ->
    expect(LinkShell).toBeDefined()

  acorn.util.test.describeShellModule LinkShell, ->

    describe 'LinkShell.Model::withLink factory constructor', ->
      Model = LinkShell.Model

      it 'should correctly construct a model from a link', ->
        links = ['http://athena.ai', 'http://www.google.com', 'http://git.io']
        _.each links, (link) ->
          modelInstance = Model.withLink link
          expect(modelInstance).toBeDefined()
          expect(modelInstance.get 'shellid').toBe LinkShell.id
          expect(modelInstance.shellid()).toBe LinkShell.id
          expect(modelInstance.get 'link').toBe link
          expect(modelInstance.link()).toBe link

      it 'should fail to construct a model with an invalid link', ->
        expect(-> Model.withLink '.ai').toThrow()
        expect(-> Model.withLink 'fdiosa').toThrow()
        expect(-> Model.withLink '421341').toThrow()
        expect(-> Model.withLink 241412).toThrow()
        expect(-> Model.withLink [1, 2, 3]).toThrow()
        expect(-> Model.withLink {link: 'http://athena.ai'}).toThrow()
        expect(-> Model.withLink 'https:/athena.ai').toThrow()
        expect(-> Model.withLink 'file:///athena.ai').toThrow()
        expect(-> Model.withLink 'ftp://athena.ai').toThrow()
