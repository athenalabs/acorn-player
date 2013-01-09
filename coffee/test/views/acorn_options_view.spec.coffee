goog.provide 'acorn.specs.player.AcornOptionsView'

goog.require 'acorn.player.AcornOptionsView'

describe 'acorn.player.AcornOptionsView', ->
  AcornOptionsView = acorn.player.AcornOptionsView

  options =
    model: new acorn.Model
      acornid: 'nyfskeqlyx'
      title: 'The Differential'

  describeView = athena.lib.util.test.describeView
  describeView AcornOptionsView, athena.lib.View, options

  it 'should be part of acorn.player', ->
    expect(AcornOptionsView).toBeDefined()

  it 'should change model.title on title blur', ->
    model = options.model.clone()
    view = new AcornOptionsView model: model
    view.render()
    expect(view.model.get 'title').toBe 'The Differential'
    view.$('#title').val 'Not The Differential'
    view.$('#title').trigger 'blur'
    expect(view.model.get 'title').toBe 'Not The Differential'

  it 'should change model.thumbnail on thumbnail blur', ->
    model = options.model.clone()
    view = new AcornOptionsView model: model
    view.render()
    expect(view.model.get 'thumbnail').toBe undefined
    view.$('#thumbnail').val 'foo.com/differential.png'
    view.$('#thumbnail').trigger 'blur'
    expect(view.model.get 'thumbnail').toBe 'http://foo.com/differential.png'


  describe 'ShellEditor:Thumbnail:Change event', ->

    it 'should change model.thumbnail if nothing in field', ->
      model = options.model.clone()
      hub = new athena.lib.View
      view = new AcornOptionsView model: model, eventhub: hub
      view.render()
      expect(view.model.get 'thumbnail').toBe undefined
      expect(view.$('#thumbnail').val()).toBe ''

      spyOn(model, 'thumbnail').andCallThrough()
      hub.trigger 'ShellEditor:Thumbnail:Change', 'foo'
      expect(model.thumbnail).toHaveBeenCalled()
      expect(model.get 'thumbnail').toBe 'foo'

    it 'should NOT change model.thumbnail if something in field', ->
      model = options.model.clone()
      model.thumbnail 'foo'
      hub = new athena.lib.View
      view = new AcornOptionsView model: model, eventhub: hub
      view.render()
      expect(view.model.get 'thumbnail').toBe 'foo'
      expect(view.$('#thumbnail').val()).toBe 'foo'

      spyOn(model, 'thumbnail').andCallThrough()
      hub.trigger 'ShellEditor:Thumbnail:Change', 'foo'
      expect(model.thumbnail).not.toHaveBeenCalled()
      expect(model.get 'thumbnail').toBe 'foo'


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a AcornOptionsView into the DOM to see how it looks.
    view = new AcornOptionsView options
    view.render()
    $player.append view.el
