goog.provide 'acorn.specs.player.OverlayView'

goog.require 'acorn.player.OverlayView'


# OverlayView
# ------------
describe 'acorn.player.OverlayView', ->
  OverlayView = acorn.player.OverlayView

  it 'should be part of acorn.player', ->
    expect(OverlayView).toBeDefined()

  it 'should derive from athena.lib.View', ->
    expect(athena.lib.util.derives OverlayView, athena.lib.View).toBe true

  it 'should set content property to point to content div on render', ->
    ov = new OverlayView()
    ov.render()
    contentDiv = ov.$ '.content'

    expect(ov.content.length).toBe 1
    expect(ov.content[0]).toBe contentDiv[0]
