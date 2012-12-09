goog.provide 'acorn.config.spec'

goog.require 'acorn.config'
goog.require 'acorn.util'

describe 'acorn.config', ->

  describe 'acorn.config.domain', ->
    domain = acorn.config.domain
    it 'should exist', ->
      expect(typeof domain).toBe('string')
    it 'should be a parsable url', ->
      expect(acorn.util.parseUrl(domain).host).toBe(domain)

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
