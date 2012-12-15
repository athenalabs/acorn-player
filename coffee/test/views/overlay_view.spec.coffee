goog.provide 'acorn.specs.player.OverlayView'

goog.require 'acorn.player.OverlayView'


# OverlayView
# ------------
describe 'acorn.player.OverlayView', ->
  OverlayView = acorn.player.OverlayView

  it 'should be part of acorn.player', ->
    expect(OverlayView).toBeDefined()


  describeView = athena.lib.util.test.describeView
  describeView OverlayView, athena.lib.View

  it 'should set content property to point to content div on render', ->
    ov = new OverlayView()
    ov.render()
    contentDiv = ov.$ '.content'

    expect(ov.content.length).toBe 1
    expect(ov.content[0]).toBe contentDiv[0]

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $body = $ 'body'

    # add a SplashView into the DOM to see how it looks.
    view = new OverlayView()
    view.render()
    view.content.append $('<h1>This is an Overlay View</h1>').attr 'style',
        'margin: 0px;'

    # populate a container in order to see it get covered up
    container = $('<div>').attr('style', 'width: 600px; height: 400px; ' +
        'overflow: hidden; position: relative;')
      .append($('<div>').attr 'style', 'width: 100%; height: 60px; '+
        'background-color: #abc;')
      .append('<p>Have some gibberish: als;dkfjasdf lasdfj dfei f jfi ' +
        'dkf k<br/>ke eid id dfi dfi iekkei dkiekjdie dki li keidjf kaiek di ' +
        'li ei jfi efja; dii kiej kdi. liefjk dki el isljfie ijfl ilei</p><p>' +
        'kaldf jdf <br/>jkei kdjfi<br/>HEILIEDKJFI</p>')
      .append($('<div>').attr 'style', 'width: 100%; height: 70px; '+
        'background-color: #cab;')
      .append($('<div>').attr 'style', 'width: 100%; height: 30px; '+
        'background-color: #bee;')

    $body.append container.append view.el
