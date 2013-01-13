goog.provide 'acorn.specs.views.CycleButtonView'

goog.require 'acorn.player.CycleButtonView'

describe 'acorn.player.CycleButtonView', ->
  CycleButtonView = acorn.player.CycleButtonView

  it 'should be part of acorn.player', ->
    expect(CycleButtonView).toBeDefined()

  validateNLoops = (input) ->
    # avoid parseInt since that will round -0.2 to 0
    n = Math.floor parseFloat input
    if n >= 0 then n else undefined

  options =
    buttonName: 'loops:'
    data: [
      {type: 'static', name: 'one', value: '1'}
      {type: 'static', name: 'infinity', value: '∞'}
      {type: 'input', name: 'n', value: 2, validate: validateNLoops}
    ]

  # construct a new cycle button view and receive pointers to the view and its
  # buttons
  setupCBV = (opts) =>
    cbv = new CycleButtonView _.defaults opts ? {}, data: options.data
    cbv.render()
    views = cbv.views
    [cbv, views]

  describeView = athena.lib.util.test.describeView
  describeView CycleButtonView, athena.lib.View, options, ->

    it 'should display the correct button name', ->
      [cbv, views] = setupCBV options

      _.each views, (view) ->
        expect(view.find('button').html()).toBe 'loops:'

    it 'should show exactly one view at all times', ->
      [cbv, views] = setupCBV()

      count = 0
      hidden = 0
      _.each views, (view) ->
        count++
        hidden++ if view.hasClass 'hidden'

      expect(count).toBe 3
      expect(hidden).toBe 2

    it 'should allow specification of the initial button view to show', ->
      for i in [0...options.data.length]
        [cbv, views] = setupCBV initialView: i

        shown = undefined
        _.each views, (view) ->
          shown = view unless view.hasClass 'hidden'

        expect(shown).toBe views[i]

    it 'should cycle through loops button views on click', ->
      [cbv, views] = setupCBV()

      # cycle through views via clicks, recording which is shown
      shownViews = for i in [0...views.length]
        hidden = 0

        for view in views
          if view.hasClass 'hidden'
            hidden++
          else
            shown = view

        expect(hidden).toBe views.length - 1
        $(shown).find('button').click()
        shown

      for view in views
        expect(_.contains shownViews, view).toBe true

    it 'should enable current state to be queried', ->
      [cbv, views] = setupCBV()

      state = cbv.currentState()
      expect(state.view).toBe views[0]
      expect(state.name).toBe 'one'
      expect(state.value).toBe '1'

      views[0].find('button').click()
      state = cbv.currentState()
      expect(state.view).toBe views[1]
      expect(state.name).toBe 'infinity'
      expect(state.value).toBe '∞'

      views[1].find('button').click()
      state = cbv.currentState()
      expect(state.view).toBe views[2]
      expect(state.name).toBe 'n'
      expect(state.value).toBe '2'

    it 'should enable the displayed view to be changed with .showView', ->
      [cbv, views] = setupCBV()

      # confirm background assumptions
      state = cbv.currentState()
      expect(state.view).toBe views[0]
      expect(state.name).toBe 'one'
      expect(state.value).toBe '1'

      cbv.showView 2
      state = cbv.currentState()
      expect(state.view).toBe views[2]
      expect(state.name).toBe 'n'
      expect(state.value).toBe '2'

      cbv.showView 1
      state = cbv.currentState()
      expect(state.view).toBe views[1]
      expect(state.name).toBe 'infinity'
      expect(state.value).toBe '∞'

    it 'should announce view and input value changes', ->
      [cbv, views] = setupCBV()

      EventSpy = athena.lib.util.test.EventSpy
      spies =
        viewSpy: new EventSpy cbv, 'change:view'
        inputValueSpy: new EventSpy cbv, 'change:input-value'
        valueSpy: new EventSpy cbv, 'change:value'

      states = [
        {view: views[0], name: 'one', value: '1'}
        {view: views[1], name: 'infinity', value: '∞'}
        {view: views[2], name: 'n', value: '2'}
      ]

      # confirm background assumptions
      expect(cbv.currentState()).toEqual states[0]

      stateChangeFns = [
        ->
          views[0].find('button').click()
          viewSpy: states[1], valueSpy: states[1]
        ->
          cbv.showView 2
          viewSpy: states[2], valueSpy: states[2]
        ->
          views[2].find('input').val 13
          views[2].find('input').change()
          state = _.extend {}, states[2], value: '13'
          inputValueSpy: state, valueSpy: state
      ]

      athena.lib.util.test.expectEventSpyBehaviors spies, stateChangeFns

    it 'should optionally validate input fields when they change or blur', ->
      [cbv, views] = setupCBV initialView: 2
      input = views[2].find 'input'

      # confirm background expectations
      expect(input.val()).toBe '2'

      input.val 5
      expect(input.val()).toBe '5'
      input.change()
      expect(input.val()).toBe '5'

      input.val -3
      expect(input.val()).toBe '-3'
      input.blur()
      expect(input.val()).toBe '5'

      input.val 1.234
      expect(input.val()).toBe '1.234'
      input.change()
      expect(input.val()).toBe '1'

      input.val '!12rc'
      expect(input.val()).toBe '!12rc'
      input.blur()
      expect(input.val()).toBe '1'

      input.val '12rc'
      expect(input.val()).toBe '12rc'
      input.change()
      expect(input.val()).toBe '12'

    it 'should look good', ->
      # setup DOM
      acorn.util.appendCss()
      $player = $('<div>').addClass('acorn-player').width(600).height(400)
        .appendTo('body')

      # add to the DOM to see how it looks
      [cbv, views] = setupCBV options
      $player.append cbv.el
