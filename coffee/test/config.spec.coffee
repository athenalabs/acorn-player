goog.provide 'acorn.specs.config'

goog.require 'acorn.config'
goog.require 'acorn.util'

describe 'acorn.config', ->

  describe 'acorn.config.url.base', ->
    base = acorn.config.url.base
    it 'should exist', ->
      expect(typeof base).toBe('string')
    it 'should have a protocol', ->
      expect(/(https?:)\/\//.test base).toBe true
    it 'should be a parsable url', ->
      href = acorn.util.parseUrl(base).href.slice(0, -1)
      expect(href).toBe(base)

  describe 'acorn.config.version', ->
    version = acorn.config.version
    it 'should exist', ->
      expect(typeof version).toBe('string')
    it 'should follow semver', ->
      expect(version.split('.').length).toBe(3)

  describe 'acorn.config.api', ->

    describe 'acorn.config.api.version', ->
      version = acorn.config.api.version
      it 'should exist', ->
        expect(typeof version).toBe('string')
      it 'should follow semver', ->
        expect(version.split('.').length).toBe(3)
