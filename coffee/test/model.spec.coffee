goog.provide 'acorn.specs.Model'

goog.require 'acorn.config'
goog.require 'acorn.Model'

describe 'acorn.Model', ->
  Model = acorn.Model

  it 'should be part of acorn', ->
    expect(acorn.Model).toBeDefined()

  it 'should derive from Backbone.Model', ->
    expect(athena.lib.util.derives Model, Backbone.Model).toBe true

  it 'should have acornid idAttribute', ->
    expect(Model::idAttribute).toBe 'acornid'

  it 'should have config-based urls', ->
    m = new Model {acornid:'hi'}
    expect(m.url()).toBe "#{acorn.config.url.base}/#{m.acornid()}"
    expect(m.apiurl()).toBe "#{acorn.config.url.api}/#{m.acornid()}"
    expect(m.embedurl()).toBe "#{acorn.config.url.base}/embed/#{m.acornid()}"

  it 'should be clonable (with deep-copies)', ->
    deep = {'a': 5}
    m = new Model {acornid:'deep', a: b: c: deep}
    expect(m.clone().attributes.a.b.c).toEqual deep
    expect(m.clone().attributes.a.b.c).not.toBe deep

    # ensure the same thing breaks on Backbone's non-deep copy
    b = new Backbone.Model {acornid:'deep', a: b: c: deep}
    expect(b.clone().attributes.a.b.c).toEqual deep
    expect(b.clone().attributes.a.b.c).toBe deep

  describe 'acorn.Model.acornid property', ->

    it 'acornid should be a property', ->
      expect(new Model().acornid()).toBe 'new'
      expect(new Model(acornid: 'hi').acornid()).toBe 'hi'

    it 'acornid should be changeable', ->
      model = new Model()
      _.each ['hello', 'I', 'love', 'you'], (id) ->
        expect(model.acornid()).not.toBe id
        expect(model.acornid(id)).toBe id
        expect(model.acornid()).toBe id

    it 'acornid should match the id Backbone.Model property', ->
      model = new Model()
      _.each ['wont', 'you', 'tell', 'me', 'your', 'name'], (id) ->
        # initialy, acornid() should not be the given id
        expect(model.acornid()).not.toBe id
        expect(model.id).not.toBe id
        expect(model.id).toBe model.acornid()

        # after setting it, both should be the given id
        expect(model.acornid(id)).toBe id
        expect(model.acornid()).toBe id
        expect(model.id).toBe id
        expect(model.id).toBe model.acornid()

  describe 'acorn.Model.shellData property', ->

    it 'shellData should be a property', ->
      expect(new Model(shell: {shell: 'S'}).shellData()).toEqual {shell: 'S'}

    it 'shellData should default to LinkShell', ->
      expect(new Model().shellData()).toEqual {shell: 'acorn.LinkShell'}

    it 'shellData should be changeable', ->
      model = new Model()
      _.each ['hello', 'I', 'love', 'you'], (type) ->
        sd = {shell: type}
        expect(model.shellData()).not.toBe sd
        expect(model.shellData(sd)).toBe sd
        expect(model.shellData()).toBe sd


  describe 'acorn.Model.sync', ->

    #TODO expand this into comprehensive tests.
    #TODO find a way to mock the server in the future.

    it 'should be able to sync', ->
      nyfskeqlyx = new acorn.Model(acornid:'nyfskeqlyx')
      spy = new athena.lib.util.test.EventSpy nyfskeqlyx, 'change'

      runs ->
        nyfskeqlyx.fetch()

      waitsFor (-> spy.triggered), 'fetch should complete', 5000

      runs ->
        shell = nyfskeqlyx.shellData()
        expect(shell.shell).toBe 'acorn.YouTubeShell'
        expect(shell.link).toBe 'https://www.youtube.com/watch?v=yYAw79386WI'
