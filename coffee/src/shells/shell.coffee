goog.provide 'acorn.shells.Shell'

goog.require 'acorn.MediaInterface'
goog.require 'acorn.shells.Registry'
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
  title: @property('title', default: '')
  description: @property('description', default: '')
  sources: @property('sources', default: [])
  timeTotal: @property('timeTotal', {default: Infinity})

  thumbnail: (thumbnail) =>
    if thumbnail?
      @set 'thumbnail', thumbnail
    @get('thumbnail') ? @defaultThumbnail()

  defaultThumbnail: @property('defaultThumbnail',
    default: acorn.config.img.acorn)

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


  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.MediaView', 'model'
    @initializeMedia()


  initializeMedia: =>
    @initializeMediaEvents @options
    @setMediaState 'init'


  controls: []


  # Returns the view's total duration in seconds
  duration: =>
    @model.timeTotal()


  render: =>
    super
    if @readyOnRender
      @setMediaState 'ready'
    @


  readyOnRender: true



# Shell.RemixView -- uniform view to edit shell data.
# ---------------------------------------------------

class Shell.RemixView extends athena.lib.View


  className: @classNameExtend 'shell-remix-view'


  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.RemixView', 'model'



acorn.registerShellModule Shell
