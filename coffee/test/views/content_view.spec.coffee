goog.provide 'acorn.specs.player.ContentView'

goog.require 'acorn.player.ContentView'
goog.require 'acorn.Model'

describe 'acorn.player.ContentView', ->
  ContentView = acorn.player.ContentView

  Shell = acorn.shells.CollectionShell

  # model for ContentView contruction
  model = new acorn.Model
    shell:
      shellid: Shell.id

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(ContentView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView ContentView, athena.lib.View, options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: Shell.MediaView
    subviewAttr: 'shellView'
    viewOptions: options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: ControlToolbarView
    subviewAttr: 'controlsView'
    viewOptions: options

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: ControlToolbarView
    subviewAttr: 'acornControlsView'
    viewOptions: options
    checkDOM: (childEl, parentEl) -> childEl.parentNode.parentNode is parentEl

  athena.lib.util.test.describeSubview
    View: ContentView
    Subview: ControlToolbarView
    subviewAttr: 'shellControlsView'
    viewOptions: options
    checkDOM: (childEl, parentEl) -> childEl.parentNode.parentNode is parentEl

  athena.lib.util.test.describeSubview {
    View: ContentView
    Subview: acorn.player.SummaryView
    subviewAttr: 'summaryView'
    viewOptions: options
  }, ->

    describe 'hovering', ->

      it 'should call onMouseenterSummaryView when mouse enters summaryView', ->
        spyOn ContentView::, 'onMouseenterSummaryView'
        contentView = new ContentView options
        contentView.render()

        expect(ContentView::onMouseenterSummaryView).not.toHaveBeenCalled()
        contentView.summaryView.$el.trigger 'mouseenter'
        expect(ContentView::onMouseenterSummaryView).toHaveBeenCalled()

      it 'should call onMouseleaveSummaryView when mouse enters summaryView', ->
        spyOn ContentView::, 'onMouseleaveSummaryView'
        contentView = new ContentView options
        contentView.render()

        expect(ContentView::onMouseleaveSummaryView).not.toHaveBeenCalled()
        contentView.summaryView.$el.trigger 'mouseleave'
        expect(ContentView::onMouseleaveSummaryView).toHaveBeenCalled()

      it 'should add \'opaque\' class when mouse enters summaryView', ->
        contentView = new ContentView options
        contentView.render()

        expect(contentView.summaryView.$el.hasClass 'opaque').toBe false
        contentView.summaryView.$el.trigger 'mouseenter'
        expect(contentView.summaryView.$el.hasClass 'opaque').toBe true

      it 'should add \'opaque-lock\' class when mouse enters summaryView', ->
        contentView = new ContentView options
        contentView.render()

        expect(contentView.summaryView.$el.hasClass 'opaque-lock').toBe false
        contentView.summaryView.$el.trigger 'mouseenter'
        expect(contentView.summaryView.$el.hasClass 'opaque-lock').toBe true

      it 'should remove \'opaque\' class when mouse leaves summaryView', ->
        contentView = new ContentView options
        contentView.render()

        contentView.summaryView.$el.addClass 'opaque'
        expect(contentView.summaryView.$el.hasClass 'opaque').toBe true
        contentView.summaryView.$el.trigger 'mouseleave'
        expect(contentView.summaryView.$el.hasClass 'opaque').toBe false

      it 'should remove \'opaque-lock\' class 1.5s after mouse enters summaryView',
          ->
        contentView = new ContentView options
        contentView.render()
        jasmine.Clock.useMock()

        expect(contentView.summaryView.$el.hasClass 'opaque-lock').toBe false
        contentView.summaryView.$el.trigger 'mouseenter'
        expect(contentView.summaryView.$el.hasClass 'opaque-lock').toBe true

        jasmine.Clock.tick 1499
        expect(contentView.summaryView.$el.hasClass 'opaque-lock').toBe true

        jasmine.Clock.tick 2
        expect(contentView.summaryView.$el.hasClass 'opaque-lock').toBe false


  it 'should render controlsView before shellView', ->
    contentView = new ContentView options
    callStack = []

    controlsSpy = spyOn(contentView.controlsView, 'render')
        .andCallFake(-> callStack.push 'controlsView.render')
    shellSpy = spyOn(contentView.shellView, 'render')
        .andCallFake(-> callStack.push 'shellView.render')

    contentView.render()
    expect(callStack[0]).toBe 'controlsView.render'
    expect(callStack[1]).toBe 'shellView.render'

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new ContentView options
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el

    view.shellView.$el.append $('<img>').attr 'src', acorn.config.img.acorn
