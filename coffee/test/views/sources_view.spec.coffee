goog.provide 'acorn.specs.player.SourcesView'

goog.require 'acorn.player.SourcesView'


# SourcesView
# -----------
describe 'acorn.player.SourcesView', ->
  SourcesView = acorn.player.SourcesView

  it 'should be part of acorn.player', ->
    expect(SourcesView).toBeDefined()

  it 'should derive from acorn.player.OverlayView', ->
    expect(athena.lib.util.derives SourcesView, acorn.player.OverlayView)
        .toBe true

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
