goog.provide 'acorn.specs.util'

goog.require 'acorn.util'


describe 'acorn.util.urlFix', ->

  it 'should fix urls', ->

    fixes = {
      'foo.com': 'http://foo.com',
    }

    _.each fixes, (desired, given) =>
      expect(acorn.util.urlFix given).toEqual desired


  it 'should keep correct urls', ->

    keeps = [
      'http://foo.com',
      'https://foo.com',
    ]

    _.each keeps, (given) =>
      expect(acorn.util.urlFix given).toEqual given


describe 'acorn.util.isAcornUrl', ->
  expectTrue = (url) ->
    expect(acorn.util.isAcornUrl(url)).toBe true

  expectFalse = (url) ->
    expect(acorn.util.isAcornUrl(url)).toBe false

  it 'should accept acorn urls', ->
    expectTrue 'http://acorn.athena.ai/hcqscjozxr'

  describe 'protocol checks', ->
    it 'should accept http', ->
      expectTrue 'http://acorn.athena.ai/hcqscjozxr'

    it 'should accept https', ->
      expectTrue 'https://acorn.athena.ai/hcqscjozxr'

    it 'should accept default protocol', ->
      expectTrue '//acorn.athena.ai/hcqscjozxr'

    it 'should NOT accept FTP', ->
      expectFalse 'ftp://acorn.athena.ai/hcqscjozxr'

    it 'should NOT accept other protocols', ->
      expectFalse 'irc://acorn.athena.ai/hcqscjozxr'
      expectFalse 'acorn://acorn.athena.ai/hcqscjozxr'
      expectFalse 'nntp://acorn.athena.ai/hcqscjozxr'
      expectFalse 'file:///acorn.athena.ai/hcqscjozxr'
      expectFalse 'data://acorn.athena.ai/hcqscjozxr'

    it 'should NOT accept malformed protocol', ->
      expectFalse '://acorn.athena.ai/hcqscjozxr'
      expectFalse 'http:/acorn.athena.ai/hcqscjozxr'
      expectFalse 'https:/acorn.athena.ai/hcqscjozxr'
      expectFalse 'http//acorn.athena.ai/hcqscjozxr'
      expectFalse 'https//acorn.athena.ai/hcqscjozxr'


  describe 'domain checks', ->
    it 'should accept acorn.athena.ai', ->
      expectTrue 'http://acorn.athena.ai/hcqscjozxr'

    it 'should accept staging-acorn.athena.ai', ->
      expectTrue 'http://staging-acorn.athena.ai/hcqscjozxr'
      expectTrue 'http://staging.acorn.athena.ai/hcqscjozxr'

    it 'should NOT accept other domains', ->
      expectFalse 'http://athena.ai/hcqscjozxr'
      expectFalse 'http://acorns.athena.ai/hcqscjozxr'
      expectFalse 'http://google.com/hcqscjozxr'


  describe 'acornid checks', ->
    it 'should accept valid acorn ids', ->
      expectTrue 'http://acorn.athena.ai/hcqscjozxr'
      expectTrue 'http://acorn.athena.ai/abcdefghij'
      expectTrue 'http://acorn.athena.ai/aaaaaaaaaa'

    it 'should accept new', ->
      expectTrue 'http://acorn.athena.ai/new'

    it 'should NOT accept invalid acorn ids', ->
      expectFalse 'http://acorn.athena.ai/hcqscjozxrfdsa'
      expectFalse 'http://acorn.athena.ai/a'
      expectFalse 'http://acorn.athena.ai/'
      expectFalse 'http://acorn.athena.ai/aaaaaaaaa1'


  describe 'title checks', ->
    it 'should accept no title', ->
      expectTrue 'http://acorn.athena.ai/hcqscjozxr'
      expectTrue 'http://acorn.athena.ai/hcqscjozxr/'

    it 'should accept title', ->
      expectTrue 'http://acorn.athena.ai/hcqscjozxr/i-will-never-give-up'

    it 'should NOT accept invalid title', ->
      expectFalse 'http://acorn.athena.ai/hcqscjozxr/i- will-never-give-up'
      expectFalse 'http://acorn.athena.ai/hcqscjozxr/fjdopsa.'



describe 'acorn.util.acornidInUrl', ->

  expectId = (url, acornid) ->
    expect(acorn.util.acornidInUrl(url)).toEqual acornid

  it 'should return acornids in acorn urls', ->
      expectId 'http://acorn.athena.ai/hcqscjozxr', 'hcqscjozxr'
      expectId 'http://acorn.athena.ai/hcqscjozxr/', 'hcqscjozxr'
      expectId 'http://acorn.athena.ai/hcqscjozxr/never-give-up', 'hcqscjozxr'

  it 'should return null otherwise', ->
      expectId 'http://athena.ai/hcqscjozxr', null
      expectId 'http://acorn.athena.ai/', null
      expectId 'http://google.com', null



describe 'acorn.util.elementInDom', ->
  elementInDom = acorn.util.elementInDom

  it 'should exist', ->
    expect(elementInDom).toBeDefined()
    expect(typeof elementInDom).toBe 'function'

  it 'should return false when called with one element not in the DOM', ->
    div = $ '<div>'
    expect(elementInDom div).toBe false

  it 'should return true when called with one element in the DOM', ->
    div = $ '<div>'
    $('body').append div
    expect(elementInDom div).toBe true
    div.remove()

  it 'should return false when called with multiple elements not in the DOM', ->
    container = $ '<div>'
    for i in [0...5]
      container.append $ '<div>'

    divs = container.children()
    expect(elementInDom divs).toBe false

  it 'should return true when called with multiple elements all in the DOM', ->
    container = $ '<div>'
    for i in [0...5]
      container.append $ '<div>'

    divs = container.children()
    $('body').append container
    expect(elementInDom divs).toBe true
    container.remove()



describe 'acorn.util.toPercent', ->
  toPercent = acorn.util.toPercent

  it 'should exist', ->
    expect(toPercent).toBeDefined()
    expect(typeof toPercent).toBe('function')

  it 'should error out if not passed a high value', ->
    n = 30
    options = {}
    expect(-> toPercent n, options).toThrow()

  it 'should not error out if passed a high value', ->
    n = 30
    options =
      high: 60

    expect(-> toPercent n, options).not.toThrow()

  it 'should convert a value to a percent between high and low values', ->
    n = 30
    options =
      high: 60
      low: 15

    expect(toPercent n, options).toBe 1 / 3 * 100

  it 'should use 0 as the low value by default', ->
    n = 30
    options =
      high: 60

    expect(toPercent n, options).toBe 1 / 2 * 100

  it 'should permit percents higher than 100% by default', ->
    n = 30
    options =
      high: 15
      low: 10

    expect(toPercent n, options).toBe 4 * 100

  it 'should permit percents lower than 0% by default', ->
    n = 0
    options =
      high: 15
      low: 10

    expect(toPercent n, options).toBe -2 * 100

  it 'should bound percents higher than 100% when passed bound: true', ->
    n = 30
    options =
      high: 15
      low: 10
      bound: true

    expect(toPercent n, options).toBe 1 * 100

  it 'should bound percents lower than 0% when passed bound: true', ->
    n = 0
    options =
      high: 15
      low: 10
      bound: true

    expect(toPercent n, options).toBe 0 * 100

  it 'should round return value after the decimal when passed decimalDigits', ->
    n = 30
    options = (n) ->
      high: 60
      low: 15
      decimalDigits: n

    expect(toPercent n, options(2)).toBe 33.33
    expect(toPercent n, options(0)).toBe 33
    expect(toPercent n, options(5)).toBe 33.33333




describe 'acorn.util.fromPercent', ->
  fromPercent = acorn.util.fromPercent

  it 'should exist', ->
    expect(fromPercent).toBeDefined()
    expect(typeof fromPercent).toBe('function')

  it 'should error out if not passed a high value', ->
    n = 30
    options = {}
    expect(-> fromPercent n, options).toThrow()

  it 'should not error out if passed a high value', ->
    n = 30
    options =
      high: 60

    expect(-> fromPercent n, options).not.toThrow()

  it 'should convert a percent to a value between high and low values', ->
    n = 1 / 3 * 100
    options =
      high: 60
      low: 15

    value = fromPercent n, options
    expect(Number value.toFixed(8)).toBe 30

  it 'should use 0 as the low value by default', ->
    n = 1 / 2 * 100
    options =
      high: 60

    value = fromPercent n, options
    expect(Number value.toFixed(8)).toBe 30

  it 'should permit percents higher than 100% by default', ->
    n = 4 * 100
    options =
      high: 15
      low: 10

    value = fromPercent n, options
    expect(Number value.toFixed(8)).toBe 30

  it 'should permit percents lower than 0% by default', ->
    n = -2 * 100
    options =
      high: 15
      low: 10

    value = fromPercent n, options
    expect(Number value.toFixed(8)).toBe 0

  it 'should bound percents higher than 100% when passed bound: true', ->
    n = 4 * 100
    options =
      high: 15
      low: 10
      bound: true

    value = fromPercent n, options
    expect(Number value.toFixed(8)).toBe 15

  it 'should bound percents lower than 0% when passed bound: true', ->
    n = -2 * 100
    options =
      high: 15
      low: 10
      bound: true

    value = fromPercent n, options
    expect(Number value.toFixed(8)).toBe 10

  it 'should round return value after the decimal when passed decimalDigits', ->
    n = 1 / 7 * 100
    options = (n) ->
      high: 60
      low: 15
      decimalDigits: n

    # 15 + 45 / 7 = 21.42857142857143
    expect(fromPercent n, options 2).toBe 21.43
    expect(fromPercent n, options 0).toBe 21
    expect(fromPercent n, options 5).toBe 21.42857



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

  padlessPairs =
    '0': 0
    '1': 1
    '10': 10
    '50': 50
    '1:00': 60
    '0.1': 0.1
    '1.1': 1.1
    '0.11': 0.11
    '0.111': 0.111
    '9.999': 9.999
    '1:10': 70
    '2:00': 120
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

  it 'should have a `secondsToTimestring` function that does not pad times when
      passed {padTime: false}', ->
    _.each padlessPairs, (sec, str) ->
      expect(Time.secondsToTimestring sec, {padTime: false}).toBe(str)

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
