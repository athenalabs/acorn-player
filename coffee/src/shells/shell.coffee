goog.provide 'acorn.shells.Shell'

goog.require 'acorn.MediaInterface'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.player.SummaryView'
goog.require 'acorn.Model'
goog.require 'acorn.util'
goog.require 'acorn.errors'



Shell = acorn.shells.Shell =


  # The unique `shell` name of an acorn Shell.
  # The convention is to namespace by vendor. e.g. `acorn.Document`.
  id: 'acorn.Shell'


  # Returns a simple title of the shell
  # Override it with your own shell-specific code.
  title: 'Shell'


  # Description of the shell
  description: 'base shell'


  # Basic icon to display throughout (using Font Awesome classes)
  icon: 'icon-sign-blank'



class Shell.Model extends athena.lib.Model


  initialize: =>
    super

    # set default property values
    unless @shellid()?
      @set {shellid: @module.id}


  # property managers
  shellid: @property('shellid', setter: false)
  title: @property 'title'
  description: @property 'description'
  thumbnail: @property 'thumbnail'
  sources: @property('sources', default: [])


  defaultAttributes: =>
    title: ''
    description: ''
    thumbnail: acorn.config.img.acorn


  _updateAttributesWithDefaults: =>
    # retrieve previous and current default thumbnails
    lastDefaults = @_lastDefaults ? {}
    currentDefaults = @_lastDefaults = @defaultAttributes()

    # update default values where appropriate
    for attr, currentDefault of currentDefaults
      modelVal = @[attr]()

      # update a model attribute if its value is the old default, is undefined,
      # or is empty
      if modelVal == lastDefaults[attr] or not modelVal? or modelVal == ''
        @[attr] currentDefault


  toString: =>
    "#{@shellid()} #{@title()}"


  # -- factory constructors --

  @withAcorn: (acornModel) => @withData acornModel.shellData()


  @withData: (data) =>
    shellModule = acorn.shellModuleWithId data.shellid
    new shellModule.Model _.clone data


  # -- unsupported --

  # disable Backbone's sync functionality
  sync: => NotSupportedError 'Backbone::sync'


# register convenience construction functions globally.
acorn.shellWithAcorn = Shell.Model.withAcorn
acorn.shellWithData = Shell.Model.withData



# Shell.MediaView -- top level media interface.
# ---------------------------------------------

class Shell.MediaView extends athena.lib.View

  # mixin acorn.MediaInterface
  _.extend @prototype, acorn.MediaInterface.prototype


  className: @classNameExtend 'shell-media-view'


  defaults: => _.extend super,
    # whether this MediaView is ready to play upon rendering
    readyOnRender: true


  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.MediaView', 'model'
    @initializeMedia()

    @summaryView = new acorn.player.SummaryView
      eventhub: @eventhub
      model: @options.model

    @on 'ProgressBar:DidProgress', @_onProgressBarDidProgress


  initializeMedia: =>
    @initializeMediaEvents @options
    @setMediaState 'init'


  controls: []


  render: =>
    super

    if @options.readyOnRender
      @setMediaState 'ready'

    # update progress bar after render finishes
    setTimeout @_updateProgressBar, 0

    @


  # Returns the view's total duration in seconds
  duration: =>
    Infinity


  # Returns the current state that the progress bar should be in
  progressBarState: =>
    if _.isFinite(@duration())
      showing: true
      progress: @percentProgress()
    else
      showing: false
      progress: 0


  percentProgress: =>
    util.toPercent @seekOffset(),
      low: 0
      high: @duration()
      bound: true


  progressFromPercent: (percentProgress) =>
    progress = util.fromPercent percentProgress,
      low: 0
      high: @duration()
      bound: true


  _updateProgressBar: =>
    state = @progressBarState()
    @trigger 'Shell:UpdateProgressBar', state.showing, state.progress


  # override as desired
  _onProgressBarDidProgress: (percentProgress) =>



# Shell.RemixView -- uniform view to edit shell data.
# ---------------------------------------------------

class Shell.RemixView extends athena.lib.View


  className: @classNameExtend 'shell-remix-view'


  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.RemixView', 'model'

    # set default thumbnail if thumbnail is undefined
    @model._updateAttributesWithDefaults()


  # override with true to tell remixerView to enable the link input field
  @activeLinkInput: false



Shell.derives = (OtherShell) ->
  athena.lib.util.derives @, OtherShell


Shell.isOrDerives = (OtherShell) ->
  athena.lib.util.isOrDerives @, OtherShell


acorn.registerShellModule Shell
