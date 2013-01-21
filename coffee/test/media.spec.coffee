goog.provide 'acorn.specs.MediaInterface'

goog.require 'acorn.MediaInterface'
goog.require 'acorn.util.test'

describe 'acorn.MediaInterface', ->
  test = athena.lib.util.test
  MediaInterface = acorn.MediaInterface

  capitalize = (s) ->
    s.replace /^[a-z]/i, (m) -> m.toUpperCase()

  it 'should be part of acorn', ->
    expect(MediaInterface).toBeDefined()

  describeStateChange = (name) ->
    Name = capitalize(name)
    describe "MediaInterface::#{name}", ->

      it 'should be a function', ->
        expect(typeof MediaInterface::[name]).toBe 'function'


      it "should trigger Will#{Name}, #{Name}, change, then Did#{Name}", ->
        flag = 0
        iface = new MediaInterface

        iface.on "Media:Will#{Name}", ->
          expect(iface.state).not.toBe name
          expect(flag).toBe 0
          flag = 1

        iface.on "Media:#{Name}", ->
          expect(iface.state).not.toBe name
          expect(flag).toBe 1
          flag = 2

        iface.on "Media:Did#{Name}", ->
          expect(iface.state).toBe name
          expect(flag).toBe 2
          flag = 3

        expect(flag).toBe(0)
        iface[name]()
        expect(flag).toBe(3)

      isInState = "isInState#{Name}"
      it "MediaInterface::#{isInState} should return true", ->
        iface = new MediaInterface
        expect(iface[isInState]()).not.toBe true
        iface[name]()
        expect(iface[isInState]()).toBe true


  describeStateChange 'init'
  describeStateChange 'ready'
  describeStateChange 'play'
  describeStateChange 'pause'
  describeStateChange 'end'

  describeFunction = (name) ->
    describe "MediaInterface::#{name}", ->
      it 'should be a function', ->
        expect(typeof MediaInterface::[name]).toBe 'function'

  describeFunction 'seekOffset'
  describeFunction 'seek'
  describeFunction 'duration'
  describeFunction 'volume'
  describeFunction 'setVolume'
  describeFunction 'width'
  describeFunction 'height'
  describeFunction 'setWidth'
  describeFunction 'setHeight'
  describeFunction 'objectFit'
  describeFunction 'setObjectFit'
