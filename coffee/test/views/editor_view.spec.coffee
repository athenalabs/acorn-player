goog.provide 'acorn.specs.player.EditorView'

goog.require 'acorn.player.EditorView'

describe 'acorn.player.EditorView', ->
  EventSpy = athena.lib.util.test.EventSpy
  EditorView = acorn.player.EditorView
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  # model for EditorView contruction
  model =
    acornModel: new Backbone.Model
      thumbnail: acorn.config.img.acorn
      acornid: 'nyfskeqlyx'
      title: 'The Differential'
    shellModel: new Backbone.Model
      shellid: 'acorn.Shell'

  # options for EditorView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(EditorView).toBeDefined()

  describeView EditorView, athena.lib.View, options

  describeSubview
    View: EditorView
    Subview: acorn.player.AcornOptionsView
    subviewAttr: 'acornOptionsView'
    viewOptions: options

  describeSubview
    View: EditorView
    Subview: acorn.player.ShellOptionsView
    subviewAttr: 'shellOptionsView'
    viewOptions: options

  describeSubview
    View: EditorView
    Subview: athena.lib.ToolbarView
    subviewAttr: 'toolbarView'
    viewOptions: options


  it 'should trigger event `Editor:Cancel` on clicking Cancel', ->
    view = new EditorView options
    spy = new EventSpy view, 'Editor:Cancel'
    view.render()
    expect(spy.triggerCount).toBe 0
    view.$('#editor-cancel-btn').trigger 'click'
    expect(spy.triggerCount).toBe 1
    view.$('#editor-cancel-btn').trigger 'click'
    expect(spy.triggerCount).toBe 2

  it 'should trigger event `Editor:Save` on clicking Save', ->
    view = new EditorView options
    spy = new EventSpy view, 'Editor:Save'
    view.render()
    expect(spy.triggerCount).toBe 0
    view.$('#editor-save-btn').trigger 'click'
    expect(spy.triggerCount).toBe 1
    view.$('#editor-save-btn').trigger 'click'
    expect(spy.triggerCount).toBe 2


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a SplashView into the DOM to see how it looks.
    view = new EditorView options
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
