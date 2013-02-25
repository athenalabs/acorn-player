goog.provide 'acorn.specs.shells.AcornLinkShell'

goog.require 'acorn.shells.AcornLinkShell'
goog.require 'acorn.util.test'


describe 'acorn.shells.AcornLinkShell', ->
  Shell = acorn.shells.Shell
  AcornLinkShell = acorn.shells.AcornLinkShell

  Model = AcornLinkShell.Model
  MediaView = AcornLinkShell.MediaView
  RemixView = AcornLinkShell.RemixView

  options =
    shellid: 'acorn.AcornLinkShell'
    link: 'http://acorn.athena.ai/nyfskeqlyx'


  acornData =
    acornid: 'nyfskeqlyx'
    shell:
      loops: 'one'
      link: 'https://www.youtube.com/watch?v=yYAw79386WI'
      shellid: 'acorn.YouTubeShell'
      timeTotal: 571
    thumbnail: 'http://acorn.athena.ai/img/acorn.png'
    owner: 'anonymous'
    title: 'New Acorn'
    updated: 'Wed Jan 02 2013 16:07:13 GMT-0800 (PST)'


  it 'should be part of acorn.shells', ->
    expect(AcornLinkShell).toBeDefined()


  acorn.Model::_fetch_original = acorn.Model::fetch
  acorn.Model::_fetch_bypass = (options) ->
    console.log 'FETCH BYPASS'
    @set acornData
    options?.success? @

  acorn.Model::fetch = acorn.Model::_fetch_bypass
  acorn.util.test.describeShellModule AcornLinkShell, options, ->
  acorn.Model::fetch = acorn.Model::_fetch_original


  describe 'AcornLinkShell.Model', ->

    it 'should retrieve acornid from link correctly', ->
      model = new Model options
      expect(model.acornid()).toBe 'nyfskeqlyx'

    it 'should have an acornModel', ->
      model = new Model options
      expect(model.acornModel instanceof acorn.Model).toBe true

    it 'should load (and call `onceLoaded` callbacks)', ->
      spy = jasmine.createSpy()
      model = new Model options
      model.onceLoaded spy
      model.onceLoaded spy
      model.onceLoaded spy
      expect(spy).not.toHaveBeenCalled()
      waitsFor (-> model.shellModel), 'model to load', 10000
      runs ->
        expect(spy).toHaveBeenCalled()
        expect(spy.callCount).toBe 3

    it 'should have a shellModel (onceLoaded)', ->
      model = new Model options
      model.onceLoaded =>
        expect(model.shellModel instanceof Shell.Model).toBe true
      waitsFor (-> model.shellModel), 'model to load', 10000


  describe 'AcornLinkShell.RemixView', ->

    it 'should update attributes with defaults once acorn model loads', ->
      spyOn RemixView::, '_updateAttributesWithDefaults'
      model = new Model options
      remixView = new RemixView model: model
      expect(RemixView::_updateAttributesWithDefaults.callCount).toBe 1

      waitsFor (-> model.shellModel), 'model to load', 10000
      runs -> expect(RemixView::_updateAttributesWithDefaults.callCount).toBe 2


    describe 'RemixView::defaultAttributes', ->

      it 'should default title to acornModel.title', ->
        model = new Model options
        remixView = new RemixView model: model

        spyOn(model.acornModel, 'title').andReturn 'spyValue'

        expect(model.acornModel.title).not.toHaveBeenCalled()
        title = remixView.defaultAttributes().title
        expect(model.acornModel.title).toHaveBeenCalled()
        expect(title).toBe 'spyValue'

      it 'should default description to acornModel.description', ->
        model = new Model options
        remixView = new RemixView model: model

        spyOn(model.acornModel, 'description').andReturn 'spyValue'

        expect(model.acornModel.description).not.toHaveBeenCalled()
        description = remixView.defaultAttributes().description
        expect(model.acornModel.description).toHaveBeenCalled()
        expect(description).toBe 'spyValue'


  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    model = new Model options

    contentView = new MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
