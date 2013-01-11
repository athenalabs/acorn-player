goog.provide 'acorn.specs.shells.ImageLinkShell'

goog.require 'acorn.shells.ImageLinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.ImageLinkShell', ->
  ImageLinkShell = acorn.shells.ImageLinkShell

  it 'should be part of acorn.shells', ->
    expect(ImageLinkShell).toBeDefined()

  acorn.util.test.describeShellModule ImageLinkShell
