goog.provide 'acorn.shells.Shell'

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
    @set {shellid: @module.id} unless @shellid()?
    @sources [] unless _.isArray @sources()
    @thumbnail acorn.config.img.acorn unless @thumbnail()?


  # property managers
  shellid: @property('shellid', false)
  title: @property 'title'
  description: @property 'description'
  sources: @property 'sources'
  thumbnail: @property 'thumbnail'


  toString: =>
    "#{@shellid()} #{@title()}"


  # -- factory constructors --

  @withAcorn: (acornModel) => @withData acornModel.shellData()


  @withData: (data) =>
    if data.shellid?
      shellClass = _.find acorn.shells, (shell) ->
        shell.id == data.shellid

    unless shellClass?
      UnregisteredShellError data.shellid

    new shellClass.Model _.clone data


  # -- unsupported --

  # disable Backbone's sync functionality
  sync: => NotSupportedError 'Backbone::sync'


# register convenience construction functions globally.
acorn.shellWithAcorn = Shell.Model.withAcorn
acorn.shellWithData = Shell.Model.withData



# Shell.MediaView -- top level media interface.
# ---------------------------------------------

class Shell.MediaView extends athena.lib.View


  className: @classNameExtend 'shell-media-view'


  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.MediaView', 'model'


  controls: []


  # -- media interface --
  # To be overriden and implemented by inheriting classes

  # Transition between play and pause states.
  play: =>
  pause: =>


  # Returns true if the media view is in 'play' state, false otherwise
  isPlaying: => false


  # Seek to the provided playback offset.
  seek: (offset) =>


  # Returns the current seek offset.
  seekOffset: => 0


  # Returns the view's total duration in seconds
  duration: => 0


  # Sets the media view's volume.
  volume: => 0
  setVolume: (volume) =>


  # Dimensions
  # The functions below expect and return dimensions in the same
  # format used to specify dimensions in CSS3. (e.g. 100%, 100px, etc.)
  width: => '100%'
  height: => '100%'
  setWidth: (width) =>
  setHeight: (height) =>


  # Object Fit
  # * contain: if you have set an explicit height and width on a replaced
  #            element, object-fit:contain will cause the content to be resized
  #            so that it is fully displayed with its intrinsic aspec ratio
  #            preserved, but still fits inside the dimensions set for the
  #            element.
  #
  # * fill:    causes the element's content to expand to completely fill the
  #            dimensions set for it, even if this does change its intrinsic
  #            aspect ratio.
  #
  # * cover:   preserves the content's intrinsic aspect ratio but alters its
  #            width and height to completely cover the element. The smaller
  #            of the two is made to fit the elemnt exactly, and the larger of
  #            the two overflows the element
  #
  # * none:    the content's intrinsic dimensions are used.
  objectFit: => 'contain'
  setObjectFit: (objectFit) =>



# Shell.RemixView -- uniform view to edit shell data.
# ---------------------------------------------------

class Shell.RemixView extends athena.lib.View


  className: @classNameExtend 'shell-remix-view'


  initialize: =>
    super

    unless @options.model
      acorn.errors.MissingParameterError 'Shell.RemixView', 'model'



acorn.registerShellModule Shell
