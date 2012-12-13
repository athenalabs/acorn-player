goog.provide 'acorn.specs.player.AcornOptionsView'

goog.require 'acorn.player.AcornOptionsView'

describe 'acorn.player.AcornOptionsView', ->
  AcornOptionsView = acorn.player.AcornOptionsView

  options =
    model: new Backbone.Model
      thumbnail: acorn.config.img.acorn
      acornid: 'nyfskeqlyx'
      title: 'The Differential'

  describeView = athena.lib.util.test.describeView
  describeView AcornOptionsView, athena.lib.View, options

  it 'should be part of acorn.player', ->
    expect(AcornOptionsView).toBeDefined()

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a AcornOptionsView into the DOM to see how it looks.
    view = new AcornOptionsView options
    view.render()
    $player.append view.el
