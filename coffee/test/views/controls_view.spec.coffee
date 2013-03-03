goog.provide 'acorn.specs.player.controls.ControlToolbarView'

goog.require 'acorn.player.controls.ControlToolbarView'
goog.require 'acorn.player.controls.ControlToggleView'
goog.require 'acorn.player.controls.PlayPauseControlToggleView'
goog.require 'acorn.player.controls.ControlView'
goog.require 'acorn.player.controls.IconControlView'
goog.require 'acorn.player.controls.ImageControlView'
goog.require 'acorn.player.controls.ElapsedTimeControlView'


describe 'acorn.player.controls.ControlToolbarView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlView = acorn.player.controls.ControlView
  IconControlView = acorn.player.controls.IconControlView
  ControlToolbar = acorn.player.controls.ControlToolbarView

  it 'should be part of acorn.player.controls', ->
    expect(ControlToolbarView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ControlToolbarView, athena.lib.View

  it 'should accept ControlViews', ->
    btns = [new ControlView, new IconControlView]
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should accept ControlToolbarViews', ->
    btns = [new ControlToolbarView, new ControlToolbarView]
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should accept ControlView ids', ->
    btns = ['Icon']
    expect(-> new ControlToolbarView buttons: btns).not.toThrow()

  it 'should not accept other things', ->
    expect(-> new ControlToolbarView buttons: ['NotAControl']).toThrow()
    expect(-> new ControlToolbarView buttons: [new acorn.lib.View]).toThrow()
    expect(-> new ControlToolbarView buttons: [{text: 'Button'}]).toThrow()
    expect(-> new ControlToolbarView buttons: [$('body')]).toThrow()
    expect(-> new ControlToolbarView buttons: [1]).toThrow()

  it 'should forward all button events', ->
    btns = [new ControlView, new ControlView, new ControlView]
    tbar = new ControlToolbarView buttons: btns
    spy = new EventSpy tbar, 'all'
    btns[0].trigger 'hi'
    expect(spy.triggerCount).toBe 1
    btns[1].trigger 'hello'
    expect(spy.triggerCount).toBe 2
    btns[2].trigger 'i'
    expect(spy.triggerCount).toBe 3
    btns[1].trigger 'am'
    expect(spy.triggerCount).toBe 4
    btns[0].trigger 'pah'
    expect(spy.triggerCount).toBe 5

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    btns = ['Icon', 'Icon', 'Icon', 'Icon', 'Icon']
    view = new ControlToolbarView buttons: btns
    view.$el.width 600
    view.render()
    $player.append view.el


describe 'acorn.player.controls.ControlToggleView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlToolbarView = acorn.player.controls.ControlToolbarView
  ControlToggleView = acorn.player.controls.ControlToggleView

  modelOptions = ->
    activeControl: 'Grid'

  viewOptions = (opts = {}) ->
    _.defaults opts,
      model: new Backbone.Model modelOptions()
      buttons: ['Grid', 'Next', 'Play', 'Acorn', 'Previous', 'Pause']

  describeView = athena.lib.util.test.describeView
  describeView ControlToggleView, ControlToolbarView, viewOptions()

  it 'should be part of acorn.player.controls', ->
    expect(ControlToggleView).toBeDefined()


  describe 'ControlToggleView::activeControl', ->

    it 'should be a function', ->
      expect(typeof ControlToggleView::activeControl).toBe 'function'

    it 'should return the control that matches model.get "activeControl"', ->
      options = viewOptions()
      view = new ControlToggleView options
      view.render()

      for controlName in options.buttons
        options.model.set 'activeControl', controlName
        controlName = controlName.toLowerCase()
        control = view.$ ".#{controlName}.control-view"
        expect(view.activeControl().el).toBe control[0]


  describe 'ControlToggleView::refreshToggle', ->

    it 'should be a function', ->
      expect(typeof ControlToggleView::refreshToggle).toBe 'function'

    it 'should be called when model changes', ->
      spyOn ControlToggleView::, 'refreshToggle'
      options = viewOptions()
      view = new ControlToggleView options

      expect(ControlToggleView::refreshToggle).not.toHaveBeenCalled()
      options.model.trigger 'change'
      expect(ControlToggleView::refreshToggle).toHaveBeenCalled()

    it 'should show the active control and hide all others', ->
      options = viewOptions()
      view = new ControlToggleView options
      view.render()
      spyOn view, 'activeControl'

      for controlName in options.buttons
        controlName = controlName.toLowerCase()
        activeControl = view.$ ".#{controlName}.control-view"
        view.activeControl.andReturn $el: activeControl
        view.refreshToggle()

        for controlName in options.buttons
          controlName = controlName.toLowerCase()
          control = view.$ ".#{controlName}.control-view"
          expect(control.hasClass 'hidden').toBe control[0] != activeControl[0]


  it 'should forward all button events', ->
    view = new ControlToggleView viewOptions()
    view.render()
    spy = new EventSpy view, 'all'
    expect(spy.triggerCount).toBe 0

    view.$('.grid.icon-control-view').click()
    expect(spy.triggerCount).toBe 1

    view.$('.next.icon-control-view').click()
    expect(spy.triggerCount).toBe 2

    view.$('.play.icon-control-view').click()
    expect(spy.triggerCount).toBe 3

    view.$('.acorn.image-control-view').click()
    expect(spy.triggerCount).toBe 4

    view.$('.previous.icon-control-view').click()
    expect(spy.triggerCount).toBe 5

    view.$('.pause.icon-control-view').click()
    expect(spy.triggerCount).toBe 6

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    options = viewOptions()
    view = new ControlToggleView options
    view.on 'GridControl:Click', -> options.model.set 'activeControl', 'Next'
    view.on 'NextControl:Click', -> options.model.set 'activeControl', 'Play'
    view.on 'PlayControl:Click', -> options.model.set 'activeControl', 'Acorn'
    view.on 'AcornControl:Click', -> options.model.set 'activeControl', 'Previous'
    view.on 'PreviousControl:Click', -> options.model.set 'activeControl', 'Pause'
    view.on 'PauseControl:Click', -> options.model.set 'activeControl', 'Grid'
    view.$el.width 600
    view.render()
    $player.append view.el


describe 'acorn.player.controls.PlayPauseControlToggleView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlToggleView = acorn.player.controls.ControlToggleView
  PlayPauseControlToggleView = acorn.player.controls.PlayPauseControlToggleView

  modelOptions = ->
    playing: true

  viewOptions = ->
    model: new Backbone.Model modelOptions()

  describeView = athena.lib.util.test.describeView
  describeView PlayPauseControlToggleView, ControlToggleView, viewOptions()

  it 'should be part of acorn.player.controls', ->
    expect(PlayPauseControlToggleView).toBeDefined()

  it 'should contain Play and Pause control views', ->
    view = new PlayPauseControlToggleView viewOptions()
    view.render()

    expect(view.$('.play.icon-control-view').length).toBe 1
    expect(view.$('.pause.icon-control-view').length).toBe 1

  it 'should hide play control and show pause control when model is playing', ->
    options = viewOptions()
    options.model.set 'playing', true
    view = new PlayPauseControlToggleView options
    view.render()

    expect(view.$('.play.icon-control-view').hasClass 'hidden').toBe true
    expect(view.$('.pause.icon-control-view').hasClass 'hidden').toBe false

  it 'should show play control and hide pause control when model is not
      playing', ->
    options = viewOptions()
    options.model.set 'playing', false
    view = new PlayPauseControlToggleView options
    view.render()

    expect(view.$('.play.icon-control-view').hasClass 'hidden').toBe false
    expect(view.$('.pause.icon-control-view').hasClass 'hidden').toBe true

  it 'should forward all button events', ->
    view = new PlayPauseControlToggleView viewOptions()
    view.render()
    spy = new EventSpy view, 'all'
    expect(spy.triggerCount).toBe 0

    view.$('.play.icon-control-view').click()
    expect(spy.triggerCount).toBe 1

    view.$('.pause.icon-control-view').click()
    expect(spy.triggerCount).toBe 2

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    options = viewOptions()
    view = new PlayPauseControlToggleView options
    view.on 'PlayControl:Click', -> options.model.set 'playing', true
    view.on 'PauseControl:Click', -> options.model.set 'playing', false
    view.$el.width 600
    view.render()
    $player.append view.el


describe 'acorn.player.controls.ControlView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlView = acorn.player.controls.ControlView
  IconControlView = acorn.player.controls.IconControlView

  describeView = athena.lib.util.test.describeView
  describeView ControlView, athena.lib.View

  it 'should be part of acorn.player.controls', ->
    expect(ControlView).toBeDefined()

  it 'should have factory constructor `withId`', ->
    expect(typeof ControlView.withId).toBe 'function'

  it 'should construct controls `withId`', ->
    expect(ControlView.withId('Icon') instanceof IconControlView).toBe true

  it 'should trigger event `Control:Click` on click', ->
    view = new ControlView
    spy = new EventSpy view, 'Control:Click'
    view.render()
    view.$el.trigger 'click'
    expect(spy.triggered).toBe true


describe 'acorn.player.controls.IconControlView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlView = acorn.player.controls.ControlView
  IconControlView = acorn.player.controls.IconControlView

  describeView = athena.lib.util.test.describeView
  describeView IconControlView, ControlView

  it 'should be part of acorn.player.controls', ->
    expect(IconControlView).toBeDefined()

  describe 'IconControlView.withIcon', ->
    it 'should be a function', ->
      expect(typeof IconControlView.withIcon).toBe 'function'

    it 'should construct controls', ->
      icon = IconControlView.withIcon 'play'
      expect(icon instanceof IconControlView).toBe true

    it 'should set the icon property', ->
      icon = IconControlView.withIcon 'play'
      expect(icon.icon).toBe 'play'

    it 'should ensure param is a string', ->
      expect(-> ControlView.withIcon 1).toThrow()
      expect(-> ControlView.withIcon []).toThrow()
      expect(-> ControlView.withIcon {}).toThrow()
      expect(-> ControlView.withIcon ->).toThrow()

  it 'should trigger event `IconControl:Click` on click', ->
    view = new IconControlView
    spy = new EventSpy view, 'IconControl:Click'
    view.render()
    view.$el.trigger 'click'
    expect(spy.triggered).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    _.each ['backward', 'play', 'pause', 'stop', 'forward'], (icon) ->
      view = IconControlView.withIcon icon
      view.render()
      $player.append view.el


describe 'acorn.player.controls.ImageControlView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlView = acorn.player.controls.ControlView
  ImageControlView = acorn.player.controls.ImageControlView

  describeView = athena.lib.util.test.describeView
  describeView ImageControlView, ControlView

  it 'should be part of acorn.player.controls', ->
    expect(ImageControlView).toBeDefined()

  describe 'ImageControlView.withUrl', ->
    it 'should be a function', ->
      expect(typeof ImageControlView.withUrl).toBe 'function'

    it 'should construct controls', ->
      image = ImageControlView.withUrl acorn.config.img.acorn
      expect(image instanceof ImageControlView).toBe true

    it 'should set the icon property', ->
      url = acorn.config.img.acorn
      image = ImageControlView.withUrl url
      expect(image.url).toBe url

    it 'should ensure param is a string url', ->
      expect(-> ControlView.withIcon 1).toThrow()
      expect(-> ControlView.withIcon []).toThrow()
      expect(-> ControlView.withIcon {}).toThrow()
      expect(-> ControlView.withIcon ->).toThrow()
      expect(-> ControlView.withIcon 'fdsiojfdpos').toThrow()
      expect(-> ControlView.withIcon 'play').toThrow()

  it 'should trigger event `ImageControl:Click` on click', ->
    view = new ImageControlView
    spy = new EventSpy view, 'ImageControl:Click'
    view.render()
    view.$el.trigger 'click'
    expect(spy.triggered).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add into the DOM to see how it looks.

    _.each [acorn.config.img.acornIcon], (url) ->
      view = ImageControlView.withUrl url
      view.render()
      $player.append view.el


describe 'acorn.player.controls.ElapsedTimeControlView', ->
  EventSpy = athena.lib.util.test.EventSpy
  ControlView = acorn.player.controls.ControlView
  ElapsedTimeControlView = acorn.player.controls.ElapsedTimeControlView

  describeView = athena.lib.util.test.describeView
  describeView ElapsedTimeControlView, ControlView

  it 'should be part of acorn.player.controls', ->
    expect(ElapsedTimeControlView).toBeDefined()

  it 'should render elapsed timestring', ->
    model = new Backbone.Model elapsed: 10, total: 20
    view = new ElapsedTimeControlView model: model
    view.render()
    expect(view.$('.elapsed-value').text()).toBe '00:10'

  it 'should render total timestring', ->
    model = new Backbone.Model elapsed: 10, total: 20
    view = new ElapsedTimeControlView model: model
    view.render()
    expect(view.$('.total').text()).toBe '00:20'

  it 'should refresh values if model changes', ->
    view = new ElapsedTimeControlView
    spyOn view, 'refreshValues'
    view.model.set 'total', 10
    expect(view.refreshValues).toHaveBeenCalled()

  it 'should have a showSeekField method that shows the seek field', ->
    view = new ElapsedTimeControlView
    view.render()

    view.$el.removeClass 'active'
    expect(view.$el.hasClass 'active').toBe false
    view.showSeekField()
    expect(view.$el.hasClass 'active').toBe true

  it 'should have a hideSeekField method that hides the seek field', ->
    view = new ElapsedTimeControlView
    view.render()

    view.$el.addClass 'active'
    expect(view.$el.hasClass 'active').toBe true
    view.hideSeekField()
    expect(view.$el.hasClass 'active').toBe false


  describe 'ElapsedTimeControlView::_seek', ->

    it 'should trigger event `ElapsedTimeControl:Seek` if seek field has a valid
        value', ->
      view = new ElapsedTimeControlView
      spy = new EventSpy view, 'ElapsedTimeControl:Seek'
      view.render()

      view.$('input').val 20
      expect(spy.triggered).toBe false
      view._seek()
      expect(spy.triggered).toBe true

    it 'should not trigger event `ElapsedTimeControl:Seek` if seek field is
        empty', ->
      view = new ElapsedTimeControlView
      spy = new EventSpy view, 'ElapsedTimeControl:Seek'
      view.render()

      expect(spy.triggered).toBe false
      view._seek()
      expect(spy.triggered).toBe false

    it 'should not trigger event `ElapsedTimeControl:Seek` if seek field lacks a
        valid value', ->
      view = new ElapsedTimeControlView
      spy = new EventSpy view, 'ElapsedTimeControl:Seek'
      view.render()

      expect(spy.triggered).toBe false
      for invalid in ['-13', 'number', ' ', '', 'lk90']
        view.$('input').val invalid
        view._seek()
        expect(spy.triggered).toBe false

    it 'should call hideSeekField', ->
      view = new ElapsedTimeControlView
      spyOn view, 'hideSeekField'
      view.render()

      expect(view.hideSeekField).not.toHaveBeenCalled()
      view._seek()
      expect(view.hideSeekField).toHaveBeenCalled()


  describe 'ElapsedTimeControlView: events', ->

    it 'should trigger event `ElapsedTimeControl:Click` on click', ->
      view = new ElapsedTimeControlView
      spy = new EventSpy view, 'ElapsedTimeControl:Click'
      view.render()
      view.$el.trigger 'click'
      expect(spy.triggered).toBe true

    it 'should call showSeekField on clicking elapsed-value timestring', ->
      spyOn ElapsedTimeControlView::, 'showSeekField'
      view = new ElapsedTimeControlView
      view.render()

      expect(ElapsedTimeControlView::showSeekField).not.toHaveBeenCalled()
      view.$('.elapsed-value').trigger 'click'
      expect(ElapsedTimeControlView::showSeekField).toHaveBeenCalled()

    it 'should not call showSeekField on general clicking', ->
      spyOn ElapsedTimeControlView::, 'showSeekField'
      view = new ElapsedTimeControlView
      view.render()

      expect(ElapsedTimeControlView::showSeekField).not.toHaveBeenCalled()
      view.$el.trigger 'click'
      expect(ElapsedTimeControlView::showSeekField).not.toHaveBeenCalled()

    it 'should call _onBlurSeekField when seek input field blurs', ->
      spyOn ElapsedTimeControlView::, '_onBlurSeekField'
      view = new ElapsedTimeControlView
      view.render()

      expect(ElapsedTimeControlView::_onBlurSeekField).not.toHaveBeenCalled()
      view.$('.seek-field').trigger 'blur'
      expect(ElapsedTimeControlView::_onBlurSeekField).toHaveBeenCalled()

    it 'should call _onKeyupSeekField on seek input field keyup', ->
      spyOn ElapsedTimeControlView::, '_onKeyupSeekField'
      view = new ElapsedTimeControlView
      view.render()

      expect(ElapsedTimeControlView::_onKeyupSeekField).not.toHaveBeenCalled()
      view.$('.seek-field').trigger 'keyup'
      expect(ElapsedTimeControlView::_onKeyupSeekField).toHaveBeenCalled()

    it 'should call _seek on input blur', ->
      view = new ElapsedTimeControlView
      spyOn view, '_seek'
      view.render()

      expect(view._seek).not.toHaveBeenCalled()
      view.$('.seek-field').blur()
      expect(view._seek).toHaveBeenCalled()

    it 'should call _seek on input keyup enter', ->
      view = new ElapsedTimeControlView
      spyOn view, '_seek'
      view.render()

      expect(view._seek).not.toHaveBeenCalled()
      e = $.Event 'keyup'
      e.keyCode = athena.lib.util.keys.ENTER
      view.$('.seek-field').trigger e
      expect(view._seek).toHaveBeenCalled()

    it 'should call hideSeekField on input keyup escape', ->
      view = new ElapsedTimeControlView
      spyOn view, 'hideSeekField'
      view.render()

      expect(view.hideSeekField).not.toHaveBeenCalled()
      e = $.Event 'keyup'
      e.keyCode = athena.lib.util.keys.ESCAPE
      view.$('.seek-field').trigger e
      expect(view.hideSeekField).toHaveBeenCalled()


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')
    $mockToolbar = $('<div>').addClass('control-toolbar-view').appendTo($player)

    # add into the DOM to see how it looks.

    _.each [[0, 0], [1, 20], [300, 500], [100000, 200000]], (pair) ->
      model = new Backbone.Model elapsed: pair[0], total: pair[1]
      view = new ElapsedTimeControlView model: model
      view.render()
      $mockToolbar.append view.el
