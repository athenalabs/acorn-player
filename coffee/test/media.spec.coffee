goog.provide 'acorn.specs.MediaInterface'

goog.require 'acorn.MediaInterface'
goog.require 'acorn.util.test'

describe 'acorn.MediaInterface', ->
  test = athena.lib.util.test
  MediaInterface = acorn.MediaInterface

  it 'should be part of acorn', ->
    expect(MediaInterface).toBeDefined()

  acorn.util.test.describeMediaInterface MediaInterface
