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

    it 'description should use acornModel.title', ->
      model = new Model options
      spyOn model.acornModel, 'title'
      waitsFor (-> model.shellModel), 'model to load', 10000
      runs ->
        expect(model.acornModel.title).not.toHaveBeenCalled()
        model.description()
        expect(model.acornModel.title).toHaveBeenCalled()



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
