goog.provide 'acorn.specs.views.TimeInputView'

goog.require 'acorn.player.TimeInputView'

describe 'acorn.player.TimeInputView', ->
  TimeInputView = acorn.player.TimeInputView

  EventSpy = athena.lib.util.test.EventSpy

  it 'should be part of acorn.player', ->
    expect(TimeInputView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView TimeInputView, athena.lib.View, ->

    timestring = acorn.util.Time.secondsToTimestring

    # construct a new time input view and receive pointers to the view and its
    # input field
    setupTIV = (opts) =>
      tiv = new TimeInputView opts
      tiv.render()
      input = tiv.$ 'input.time-field'
      [tiv, input]

    it 'should set time to value param when initialized therewith', ->
      times = [0, 30, 60.66, 99]

      for time in times
        [tiv, input] = setupTIV value: time
        expect(tiv.value()).toBe time

    it 'should display time as a timestring in input field', ->
      times = [0, 30, 60.66, 99]

      for time in times
        [tiv, input] = setupTIV value: time
        expect(tiv.value()).toBe time
        expect(input.val()).toBe timestring time

    it 'should update display value on change, blur, ENTER, and ESC', ->
      [tiv, input] = setupTIV()

      times = [0, 30, 60.66, 99]

      for event in ['change', 'blur']
        for time in times
          input.val time
          expect(input.val()).toBe "#{time}"
          expect(tiv.value()).not.toBe time

          input[event]()
          expect(input.val()).toBe timestring time
          expect(tiv.value()).toBe time

      for key in ['ENTER', 'ESCAPE']
        for time in times
          input.val time
          expect(input.val()).toBe "#{time}"
          expect(tiv.value()).not.toBe time

          e = $.Event 'keyup', {which: athena.lib.util.keys[key]}
          input.trigger e
          expect(input.val()).toBe timestring time
          expect(tiv.value()).toBe time

    it 'should accept numbers and timestrings and ignore bad values', ->
      [tiv, input] = setupTIV()

      times =
        20: 20
        '40': 40
        '#75': undefined
        '13m9s': 13
        'forty-five': undefined
        'add-ten': undefined
        '2:08': 128
        '01:12': 72
        '213': 213

      for raw, processed of times
        # if no valid processed value, expect time to be reset to current value
        processed ?= tiv.value()

        input.val raw
        input.change()
        expect(input.val()).toBe timestring processed
        expect(tiv.value()).toBe processed

    it 'should enforce time min and max as boundaries', ->
      [tiv, input] = setupTIV {min: 13, value: 26, max: 39}

      # confirm background assumptions
      expect(input.val()).toBe timestring 26
      expect(tiv.value()).toBe 26

      # test that min truncates
      input.val 10
      input.change()
      expect(input.val()).toBe timestring 13
      expect(tiv.value()).toBe 13

      # test that max truncates
      input.val 100
      input.change()
      expect(input.val()).toBe timestring 39
      expect(tiv.value()).toBe 39

    it 'should permit value, min, and max to be changed programatically', ->
      [tiv, input] = setupTIV {min: 13, value: 26, max: 39}

      # confirm background assumptions
      expect(input.val()).toBe timestring 26
      expect(tiv.value()).toBe 26

      # test that value can be set
      tiv.value 20
      expect(input.val()).toBe timestring 20
      expect(tiv.value()).toBe 20

      # test that min can be changed
      tiv.setMin 30
      expect(input.val()).toBe timestring 30
      expect(tiv.value()).toBe 30

      tiv.value 15
      expect(input.val()).toBe timestring 30
      expect(tiv.value()).toBe 30

      tiv.setMin 10
      tiv.value 15
      expect(input.val()).toBe timestring 15
      expect(tiv.value()).toBe 15

      tiv.setMin 20
      expect(input.val()).toBe timestring 20
      expect(tiv.value()).toBe 20

      # test that max can be changed
      tiv.value 30
      tiv.setMax 25
      expect(input.val()).toBe timestring 25
      expect(tiv.value()).toBe 25

      tiv.value 40
      expect(input.val()).toBe timestring 25
      expect(tiv.value()).toBe 25

      tiv.setMax 50
      tiv.value 40
      expect(input.val()).toBe timestring 40
      expect(tiv.value()).toBe 40

      tiv.setMax 30
      expect(input.val()).toBe timestring 30
      expect(tiv.value()).toBe 30

    it 'should trigger `TimeInputView:TimeDidChange` when the time has
        changed', ->
      [tiv, input] = setupTIV()

      spies =
        spy: new EventSpy tiv, 'TimeInputView:TimeDidChange'

      setTimeFns = [
        ->
          input.val 20
          input.change()
          spy: 20
        ->
          input.val 20
          input.change()
          undefined
        ->
          tiv.value '40'
          spy: 40
        ->
          tiv.setMax 35
          spy: 35
        ->
          input.val '#75'
          undefined
        ->
          tiv.value '13m9s'
          spy: 13
        ->
          tiv.value '13'
          undefined
      ]

      athena.lib.util.test.expectEventSpyBehaviors spies, setTimeFns

    it 'should glow blue for half a second after changing', ->
      [tiv, input] = setupTIV()
      jasmine.Clock.useMock()

      expect(tiv.controlGroup.hasClass 'info').toBe false

      tiv.value 10
      expect(tiv.controlGroup.hasClass 'info').toBe true

      jasmine.Clock.tick(499)
      expect(tiv.controlGroup.hasClass 'info').toBe true

      jasmine.Clock.tick(2)
      expect(tiv.controlGroup.hasClass 'info').toBe false

    it 'should have a configuable name', ->
      [tiv, input] = setupTIV name: 'reacTIV'
      expect(tiv.$('.add-on').text()).toBe 'reacTIV'

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

        # add to the DOM to see how it looks
        [tiv, input] = setupTIV max: 100
        $player.append tiv.el

