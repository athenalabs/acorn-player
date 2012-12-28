goog.provide 'acorn.specs.shells.VimeoShell'

goog.require 'acorn.shells.VimeoShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.VimeoShell', ->
  VimeoShell = acorn.shells.VimeoShell

  Model = VimeoShell.Model
  MediaView = VimeoShell.MediaView
  PlayerView = VimeoShell.PlayerView
  RemixView = VimeoShell.RemixView

  modelOptions = -> link: 'http://vimeo.com/8201078'
  viewOptions = ->
    model: new Model modelOptions()
    eventhub: _.extend {}, Backbone.Events

  it 'should be part of acorn.shells', ->
    expect(VimeoShell).toBeDefined()

  acorn.util.test.describeShellModule VimeoShell, modelOptions(), ->
