goog.provide 'acorn.specs.player.PlayerView'

goog.require 'acorn.player.PlayerView'

describe 'acorn.player.PlayerView', ->
  PlayerView = acorn.player.PlayerView
  derives = athena.lib.util.derives

  # model for PlayerView contruction
  model =
    shellModel: new Backbone.Model
    acornModel: new Backbone.Model
      thumbnail: acorn.config.img.acorn
      type: 'image'

  # emulate shell, object with a ContentView property
  shell = ContentView: athena.lib.View
  model.shellModel.shell = shell

  # options for ContentView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(acorn.player.PlayerView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView PlayerView, athena.lib.View, options

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add a PlayerView into the DOM to see how it looks.
    view = new PlayerView model: model
    view.$el.width 600
    view.$el.height 400
    view.render()
    $player.append view.el

    view.eventhub.trigger 'show:splash'
