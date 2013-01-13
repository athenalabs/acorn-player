goog.provide 'acorn.specs.shells.AcornLinkShell'

goog.require 'acorn.shells.AcornLinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.AcornLinkShell', ->
  Shell = acorn.shells.Shell
  AcornLinkShell = acorn.shells.AcornLinkShell

  it 'should be part of acorn.shells', ->
    expect(AcornLinkShell).toBeDefined()

  options =
    shellid: 'acorn.AcornLinkShell'
    link: 'http://acorn.athena.ai/nyfskeqlyx'


  acorn.util.test.describeShellModule AcornLinkShell, options, ->

    describe 'AcornLinkShell.Model', ->

      it 'should retrieve acornid from link correctly', ->
        model = new AcornLinkShell.Model options
        expect(model.acornid()).toBe 'nyfskeqlyx'

      it 'should have an acornModel', ->
        model = new AcornLinkShell.Model options
        expect(model.acornModel instanceof acorn.Model).toBe true

      it 'should load (and call `onceLoaded` callbacks)', ->
        spy = jasmine.createSpy()
        model = new AcornLinkShell.Model options
        model.onceLoaded spy
        model.onceLoaded spy
        model.onceLoaded spy
        expect(spy).not.toHaveBeenCalled()
        waitsFor (-> model.shellModel), 'model to load', 10000
        runs ->
          expect(spy).toHaveBeenCalled()
          expect(spy.callCount).toBe 3

      it 'should have a shellModel (onceLoaded)', ->
        model = new AcornLinkShell.Model options
        model.onceLoaded =>
          expect(model.shellModel instanceof Shell.Model).toBe true
        waitsFor (-> model.shellModel), 'model to load', 10000

      it 'description should use acornModel.title', ->
        model = new AcornLinkShell.Model options
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

    model = new AcornLinkShell.Model options

    contentView = new AcornLinkShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new AcornLinkShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
