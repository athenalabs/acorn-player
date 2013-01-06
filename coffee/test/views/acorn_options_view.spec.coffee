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

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a AcornOptionsView into the DOM to see how it looks.
    view = new AcornOptionsView options
    view.render()
    $player.append view.el
