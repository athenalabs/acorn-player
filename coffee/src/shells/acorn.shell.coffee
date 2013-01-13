goog.provide 'acorn.shells.AcornLinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'



LinkShell = acorn.shells.LinkShell
AcornLinkShell = acorn.shells.AcornLinkShell =

  id: 'acorn.AcornLinkShell'
  title: 'AcornLinkShell'
  description: 'A shell for acorn links.'
  icon: 'icon-play'
  validLinkPatterns: [
    acorn.util.urlRegEx('acorn\.athena\.ai\/([A-Za-z]{10})/?')
  ]


class AcornLinkShell.Model extends LinkShell.Model


  initialize: =>
    super
    @acornModel = acorn @acornid()
    @acornModel.fetch
      success: =>
        @shellModel = acorn.shellWithData @acornModel.shellData()
        @trigger 'AcornLinkModel:Loaded'


  onceLoaded: (callback) =>
    if @shellModel
      callback()
    else
      @once 'AcornLinkModel:Loaded', callback


  acornid: =>
    link = @get('link')
    pattern = _.find @module.validLinkPatterns, (pattern) -> pattern.test link
    unless pattern
      ValueError 'Incorrect acorn link, no acornid found.'
    pattern.exec(link)[2]


  description: =>
    @acornModel.title() ? ''


  # duration of one video loop given current splicing
  duration: =>
    @shellModel?.duration() ? Infinity


class AcornLinkShell.MediaView extends LinkShell.MediaView


  className: @classNameExtend 'acorn-link-shell'


  initialize: =>
    super

    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: []
      eventhub: @eventhub

    @model.onceLoaded @initializeMediaView
    @

  initializeMediaView: =>
    @mediaView = new @model.shellModel.module.MediaView
      model: @model.shellModel
      eventhub: @eventhub

    # fwd all events.
    @on 'all', _.bind(@mediaView.trigger, @)

    if @mediaView.controlsView
      @controlsView.buttons = [@mediaView.controlsView]
    else
      @controlsView.buttons = @mediaView.controls
    @controlsView.initializeButtons()


  render: =>
    super
    @$el.empty()
    @model.onceLoaded @renderMediaView
    @


  renderMediaView: =>
    @$el.append @mediaView.render().el
    @controlsView.softRender()
    @


  # actions

  play: =>
    @mediaView.play()


  pause: =>
    @mediaView.pause()


  seek: (seconds) =>
    @mediaView.seek seconds


  # state getters

  isPlaying: =>
    @mediaView.isPlaying() ? false


  seekOffset: =>
    @mediaView.seekOffset() ? 0


  duration: =>
    @mediaView.duration()



class AcornLinkShell.RemixView extends LinkShell.RemixView


  className: @classNameExtend 'acorn-link-shell'


  initialize: =>
    super
    @player = new acorn.player.Player model: @model.acornModel


  render: =>
    super
    @$el.empty()
    @$el.append @player.render().el
    @


# Register the shell with the acorn object.
acorn.registerShellModule AcornLinkShell
