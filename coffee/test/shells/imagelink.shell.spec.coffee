goog.provide 'acorn.specs.shells.ImageLinkShell'

goog.require 'acorn.shells.ImageLinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.ImageLinkShell', ->
  ImageLinkShell = acorn.shells.ImageLinkShell

  Model = ImageLinkShell.Model
  MediaView = ImageLinkShell.MediaView
  RemixView = ImageLinkShell.RemixView

  it 'should be part of acorn.shells', ->
    expect(ImageLinkShell).toBeDefined()

  acorn.util.test.describeShellModule ImageLinkShell, ->

    imageLink = 'http://image.com/image.jpg'

    modelOptions = ->
      link: imageLink

    viewOptions = ->
      model: new Model modelOptions()
      eventhub: _.extend {}, Backbone.Events


    describe 'ImageLinkShell.Model', ->

      describe 'Model::defaultAttributes', ->

        it 'should default thumbnail to link', ->
          model = new Model modelOptions()
          expect(model.defaultAttributes().thumbnail).toBe imageLink
