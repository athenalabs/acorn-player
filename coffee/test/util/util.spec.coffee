goog.provide 'acorn.specs.util'

goog.require 'acorn.util'


describe 'acorn.util.Time', ->
  Time = acorn.util.Time
  it 'should exist', ->
    expect(Time).toBeDefined()
    expect(typeof Time).toBe('function')

  pairs =
    '00:00': 0
    '00:01': 1
    '00:10': 10
    '00:50': 50
    '01:00': 60
    '00:00.1': 0.1
    '00:01.1': 1.1
    '00:00.11': 0.11
    '00:00.111': 0.111
    '00:09.999': 9.999
    '01:10': 70
    '02:00': 120
    '10:00': 600
    '10:10': 610
    '11:11': 671
    '1:00:00': 3600
    '10:00:00': 36000
    '111:11:11': 400271
    '111:11:11.111': 400271.111
    '123:46:07.89': 445567.89

  it 'should have a working, static `timestringToSeconds` function', ->
    expect(typeof Time.timestringToSeconds).toBe('function')
    _.each pairs, (sec, str) ->
      expect(Time.timestringToSeconds str).toBe(sec)

  it 'should have a working, static `secondsToTimestring` function', ->
    expect(typeof Time.secondsToTimestring).toBe('function')
    _.each pairs, (sec, str) ->
      expect(Time.secondsToTimestring sec).toBe(str)

  it 'constructing the object should work', ->
    t = new Time(0)
    expect(t).toBeDefined()
    expect(t.time).toBe(0)
    expect(typeof t).toBe('object')
    expect(t.constructor).toBe(Time)

  it 'should have a working `seconds` method', ->
    _.each pairs, (sec, str) ->
      expect(new Time(sec).seconds()).toBe(sec)
      expect(new Time(str).seconds()).toBe(sec)

  it 'should have a working `timestring` method', ->
    _.each pairs, (sec, str) ->
      expect(new Time(sec).timestring()).toBe(str)
      expect(new Time(str).timestring()).toBe(str)

  it 'should have a working, static `secondsToTimestring`', ->
    expect(typeof Time.secondsToTimestring).toBe('function')
    _.each pairs, (sec, str) ->
      expect(Time.secondsToTimestring sec).toBe(str)

  # TODO write tests that should fail

describe 'acorn.util.Timer', ->
  Timer = acorn.util.Timer

  it 'should be part of acorn.util', ->
    expect(Timer).toBeDefined()

  it 'should be a class', ->
    expect(typeof Timer).toBe 'function'

  it 'should have startTick method', ->
    expect(typeof Timer::startTick).toBe 'function'

  it 'should have stopTick method', ->
    expect(typeof Timer::stopTick).toBe 'function'

  it 'should have onTick method', ->
    expect(typeof Timer::onTick).toBe 'function'

  it 'should call callback at a constant interval', ->
    jasmine.Clock.useMock()

    callback = jasmine.createSpy('timerCallback')
    object = prop: 'value'
    timer = new Timer 50, callback, object

    jasmine.Clock.tick(101)

    timer.startTick()
    jasmine.Clock.tick(201)

    timer.stopTick()
    jasmine.Clock.tick(301)

    expect(callback.calls.length).toBe 4
    expect(callback.calls[0].args[0]).toBe object


describe 'acorn.util.parseUrl', ->
  parseUrl = acorn.util.parseUrl

  it 'should exist', ->
    expect(typeof parseUrl).toBe('function')

  urls =
    'athena.ai':
      href: 'http://athena.ai/'
      protocol: 'http:'
      hostname: 'athena.ai'
      host: 'athena.ai'
      port: ''
      pathname: '/'
      search: ''
      hash: ''
      resource: '/'
      extension: '/'

    'ftp://dev.www1.athena.ai:9998/test.py?uiop#rty':
      href: 'ftp://dev.www1.athena.ai:9998/test.py?uiop#rty'
      protocol: 'ftp:'
      hostname: 'dev.www1.athena.ai'
      host: 'dev.www1.athena.ai:9998'
      port: '9998'
      pathname: '/test.py'
      search: '?uiop'
      hash: '#rty'
      resource: '/test.py?uiop'
      extension: 'py'

  it 'should properly parse urls', ->
    _.each urls, (vars, url) ->
      parsed = parseUrl url
      _.each vars, (val, key) ->
        expect(parsed[key]).toBe(val)
