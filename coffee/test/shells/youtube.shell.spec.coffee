goog.provide 'acorn.specs.shells.YouTubeShell'

goog.require 'acorn.shells.YouTubeShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.YouTubeShell', ->
  YouTubeShell = acorn.shells.YouTubeShell

  Model = YouTubeShell.Model
  MediaView = YouTubeShell.MediaView
  PlayerView = YouTubeShell.PlayerView
  RemixView = YouTubeShell.RemixView

  modelOptions = -> link: 'http://www.youtube.com/watch?v=WgBeu3FVi60'
  viewOptions = ->
    model: new Model modelOptions()
    eventhub: _.extend {}, Backbone.Events

  it 'should be part of acorn.shells', ->
    expect(YouTubeShell).toBeDefined()

  acorn.util.test.describeShellModule YouTubeShell, modelOptions(), ->
