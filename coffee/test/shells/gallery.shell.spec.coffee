goog.provide 'acorn.specs.shells.GalleryShell'

goog.require 'acorn.shells.GalleryShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.GalleryShell', ->
  GalleryShell = acorn.shells.GalleryShell

  Model = GalleryShell.Model
  MediaView = GalleryShell.MediaView
  RemixView = GalleryShell.RemixView

  it 'should be part of acorn.shells', ->
    expect(GalleryShell).toBeDefined()

  acorn.util.test.describeShellModule GalleryShell, ->
