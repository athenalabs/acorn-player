goog.provide 'acorn.specs.shells.SlideshowShell'

goog.require 'acorn.shells.SlideshowShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.SlideshowShell', ->
  SlideshowShell = acorn.shells.SlideshowShell

  Model = SlideshowShell.Model
  MediaView = SlideshowShell.MediaView
  RemixView = SlideshowShell.RemixView

  it 'should be part of acorn.shells', ->
    expect(SlideshowShell).toBeDefined()

  acorn.util.test.describeShellModule SlideshowShell, ->
