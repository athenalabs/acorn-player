goog.provide 'acorn.specs.player.MediaPlayerView'

goog.require 'acorn.player.MediaPlayerView'
goog.require 'acorn.shells.VideoLinkShell'
goog.require 'acorn.util.test'

describe 'acorn.player.MediaPlayerView', ->
  MediaPlayerView = acorn.player.MediaPlayerView
  test = athena.lib.util.test

  Model = acorn.shells.VideoLinkShell.Model
  options = ->
    model: new Model {timeTotal: 300}
    eventhub: _.extend {}, Backbone.Events


  it 'should be part of acorn.player', ->
    expect(MediaPlayerView).toBeDefined()

  test.describeView MediaPlayerView, athena.lib.View, options()

  acorn.util.test.describeMediaInterface MediaPlayerView, options()
