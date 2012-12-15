goog.provide 'acorn.specs.player.SourcesView'

goog.require 'acorn.player.SourcesView'


# SourcesView
# -----------
describe 'acorn.player.SourcesView', ->
  SourcesView = acorn.player.SourcesView

  it 'should be part of acorn.player', ->
    expect(SourcesView).toBeDefined()

  describeView = athena.lib.util.test.describeView
  describeView SourcesView, acorn.player.OverlayView, {shell: 'dummy'}

  it 'should require shell parameter on construction', ->
    expect(-> new SourcesView {shell: 'dummy'}).not.toThrow()
    expect(-> new SourcesView()).toThrow()

  it 'should handle close-button clicks', ->
    expect(SourcesView::onClickClose).toBeDefined()
    expect(SourcesView::events()['click button#close']).toBe 'onClickClose'

    eventhub = _.extend {}, Backbone.Events
    eventSpy = new athena.lib.util.test.EventSpy eventhub, 'close:sources'

    sv = new SourcesView {shell: 'dummy', eventhub: eventhub}
    sv.render()

    expect(eventSpy.triggered).toBe false
    sv.$('#close').click()
    expect(eventSpy.triggered).toBe true

  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $body = $ 'body'

    # add a SplashView into the DOM to see how it looks.
    view = new SourcesView {shell: 'dummy'}
    view.render()

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
