goog.provide 'acorn.specs.player.AcornOptionsView'

goog.require 'acorn.player.AcornOptionsView'

describe 'acorn.player.AcornOptionsView', ->
  AcornOptionsView = acorn.player.AcornOptionsView

  it 'should be part of acorn.player', ->
    expect(acorn.player.AcornOptionsView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives AcornOptionsView, athena.lib.View).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a AcornOptionsView into the DOM to see how it looks.
    model = new Backbone.Model
      thumbnail: acorn.config.img.acorn
      acornid: 'nyfskeqlyx'
      title: 'The Differential'

    view = new AcornOptionsView model: model
    view.render()
    $player.append view.el
