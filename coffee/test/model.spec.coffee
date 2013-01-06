goog.provide 'acorn.specs.Model'

goog.require 'acorn.config'
goog.require 'acorn.Model'

describe 'acorn.Model', ->
  Model = acorn.Model
  EventSpy = athena.lib.util.test.EventSpy

  it 'should be part of acorn', ->
    expect(Model).toBeDefined()

  it 'should derive from athena.lib.Model', ->
    expect(athena.lib.util.derives Model, athena.lib.Model).toBe true

  it 'should have acornid idAttribute', ->
    expect(Model::idAttribute).toBe 'acornid'

  it 'should have config-based urls', ->
    m = new Model {acornid:'hi'}
    expect(m.urlRoot()).toBe "#{acorn.config.url.api}/acorn"
    expect(m.url()).toBe "#{acorn.config.url.api}/acorn/#{m.acornid()}"
    expect(m.pageUrl()).toBe "#{acorn.config.url.base}/#{m.acornid()}"
    expect(m.embedUrl()).toBe "#{acorn.config.url.base}/embed/#{m.acornid()}"

  it 'should be clonable (with deep-copies)', ->
    deep = {'a': 5}
    m = new Model {acornid:'deep', a: b: c: deep}
    expect(m.clone().attributes.a.b.c).toEqual deep
    expect(m.clone().attributes.a.b.c).not.toBe deep

    # ensure the same thing breaks on Backbone's non-deep copy
    b = new Backbone.Model {acornid:'deep', a: b: c: deep}
    expect(b.clone().attributes.a.b.c).toEqual deep
    expect(b.clone().attributes.a.b.c).toBe deep

  it 'should have a toJSONString function', ->
    expect(typeof Model::toJSONString).toBe 'function'
    m = new Model {acornid:'deep', a: b: c: {'a': 5}}
    s = m.toJSONString()
    expect(JSON.stringify m.attributes).toEqual s


  describeProperty = athena.lib.util.test.describeProperty
  describeProperty Model, 'title', {}, default: 'New Acorn'
  describeProperty Model, 'thumbnail', {}, default: acorn.config.img.acorn
  describeProperty Model, 'owner', {},


  describeProperty Model, 'acornid', {}, {}, ->
    it 'acornid should match the id athena.lib.Model property', ->
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
      sd = {shellid: 'S'}
      expect(new Model(shell: sd).shellData()).toEqual sd

    it 'shellData should default to EmptyShell', ->
      expect(new Model().shellData()).toEqual {shellid: 'acorn.EmptyShell'}

    it 'shellData should be changeable', ->
      model = new Model()
      _.each ['hello', 'I', 'love', 'you'], (type) ->
        sd = {shellid: type}
        expect(model.shellData()).not.toBe sd
        expect(model.shellData(sd)).toBe sd
        expect(model.shellData()).toBe sd



  describe 'acorn.Model.sync', ->

    #TODO expand this into comprehensive tests.
    #TODO find a way to mock the server in the future.

    # Uncomment this to run locally:
    # acorn.config.setDomain 'localhost.athena.ai:8000'

    acornid = undefined
    nyfskeqlyx = 'https://www.youtube.com/watch?v=yYAw79386WI'

    it 'should be able to create', ->
      m = new Model shell:
        shellid: 'acorn.YouTubeShell'
        link: nyfskeqlyx
      spy = new EventSpy m, 'sync'
      runs -> m.save()
      waitsFor (-> spy.triggered), 'save should complete',
        acorn.config.test.timeout
      runs ->
        acornid = m.acornid()
        expect(m.acornid()).toBeDefined()
        expect(spy.triggered).toBe true


    it 'should be able to fetch', ->
      m = new Model acornid: acornid
      spy = new EventSpy m, 'sync'

      runs -> m.fetch()
      waitsFor (-> spy.triggered), 'sync should complete',
        acorn.config.test.timeout
      runs ->
        shell = m.shellData()
        expect(shell.shellid).toBe 'acorn.YouTubeShell'
        expect(shell.link).toBe nyfskeqlyx

    it 'should be able to save', ->
      m1 = new Model acornid: acornid
      m2 = new Model acornid: acornid
      spy = new EventSpy m1, 'sync'
      date = new Date().toString()

      runs -> m1.fetch()

      waitsFor (-> spy.triggered), 'fetch should complete',
        acorn.config.test.timeout
      runs ->
        expect(m1.get 'updated').not.toEqual date
        m1.set({updated: date})
        m1.synced = false
        m1.save {},
          success: => m1.synced = true
          error: (model, jqXHR, options) =>
            expect(jqXHR).not.toBeDefined()
            m1.synced = true

      waitsFor (=> m1.synced), 'sync should complete',
        acorn.config.test.timeout
      runs ->
        expect(m1.get 'updated').toEqual date
        expect(m2.get 'updated').not.toEqual date
        expect(m2.get 'updated').not.toEqual m1.get 'updated'

        spy = new EventSpy m2, 'change'
        m2.fetch()

      waitsFor (-> spy.triggered), 'fetch should complete',
        acorn.config.test.timeout

      runs ->
        expect(m1.get 'updated').toEqual date
        expect(m2.get 'updated').toEqual date
        expect(m2.get 'updated').toEqual m1.get 'updated'


    it 'should be able to delete', ->
      m = new acorn.Model acornid: acornid
      spy = new EventSpy m, 'sync'
      date = new Date().toString()

      runs -> m.destroy()

      waitsFor (-> spy.triggered), 'destroy should complete',
        acorn.config.test.timeout

      runs ->
        expect(m.acornid()).toEqual(acornid)
