goog.provide 'acorn.shells.CollectionShell'

goog.require 'acorn.shells.Shell'



Shell = acorn.shells.Shell


# CollectionShell -- one shell to contain them all.
#
# The idea behind CollectionShell is that it provides a generic group for
# other shells. It provides the basic, core functionality necessary
# to construct one unified shell out of other "subshells".
#
# Types of media groups made possible by CollectionShell are, for example:
# * Playlists
# * Galleries
# * Slideshows
# * Spliced Video
#
# CollectionShell does its magic by a simple abstraction, it interacts with
# acorn as one single shell, and then directs actions/events to the specific
# subshells that should get them.
#
# CollectionShell is represented by a list (array) of subshells.
# For example:
#
# {
#   "shellid": "acorn.CollectionShell",
#   "shells": [
#     {
#       "link": "http://www.youtube.com/watch?v=OQSNhk5ICTI",
#       "shell": "acorn.YouTubeShell",
#     },
#     {
#       "link": "http://www.youtube.com/watch?v=MX0D4oZwCsA",
#       "shell": "acorn.YouTubeShell"
#     }
#   ]
# }
#
# Note that the order of the shells in the array is significant, as
# CollectionShell uses this order to present the subshells.

CollectionShell = acorn.shells.CollectionShell =

  id: 'acorn.CollectionShell'
  title: 'CollectionShell'
  description: 'Collection shell'
  icon: 'icon-sitemap'



class CollectionShell.Model extends Shell.Model


  initialize: =>
    super

    unless @get 'shells'
      @set 'shells', []


  defaultThumbnail: =>
    @shells().first()?.thumbnail() or super


  # lazily construct shells collection
  shells: =>
    unless @_shells
      @_shells = new Backbone.Collection
      @_syncShells()

      @_shells.on 'add', @_onAddShell
      @_shells.on 'remove', @_onRemoveShell
      @_shells.on 'reset', @_onResetShells

      # should really resync when change:shells is called
      # externally, but need to figure out a good way to
      # prevent event-loops. TODO
      # @on 'change:shells', @_syncShells

    @_shells


  _syncShells: =>
    shells = _.map @get('shells'), Shell.Model.withData
    @_shells.reset shells


  _onAddShell: (shell, collection, options) =>
    if shell is @
      ValueError shell, 'cannot be added to itself'

    unless shell instanceof Shell.Model
      TypeError shell, 'Shell.Model'

    options ?= {}
    index = collection.indexOf shell
    data = shell.toJSON() # deep clone

    shells = _.clone @get 'shells'
    shells.splice index, 0, data

    # trigger change events. (splicing array doesn't)
    @set shells: shells, options


  _onRemoveShell: (shell, collection, options) =>
    if shell is @
      ValueError shell, 'cannot be removed from itself'

    unless shell instanceof Shell.Model
      TypeError shell, 'Shell.Model'

    options ?= {}
    index = collection.indexOf shell

    shells = _.clone @get 'shells'
    shells.splice index, 1

    # trigger change events. (splicing array doesn't)
    @set shells: shells, options


  _onResetShells: (collection, options) =>

    options ?= {}
    data = collection.map (shell) => shell.toJSON() # deep clone
    shells = _.clone @get 'shells'

    # if its the same, we're done
    if _.isEqual shells, data
      return


    # trigger change events.
    @set shells: data, options



# Render each subshell in sequence. Shows each shell individually, keeping
# track of the current shell (through currentView). Rendering of the media
# is left entirely to the specific subshell.
#
# It listens to the 'left', 'list', and 'right' events from the
# Player.ContentView to navigate.

class CollectionShell.MediaView extends Shell.MediaView


  className: @classNameExtend 'collection-shell'


  defaults: => _.extend super,
    playOnReady: true
    readyOnRender: false

    # whether the collection shell is ready when the first shell is
    readyOnFirstShellReady: true

    # whether or not to show first subshell on render
    showFirstSubshellOnRender: true

    # whether play continues between subshell transitions
    playOnChangeShell: true

    # whether or not to show subshell controls
    showSubshellControls: true

    # whether or not to show subshell summary view
    showSubshellSummary: true

    # whether or not to advance to the next shell once one ends
    autoAdvanceOnEnd: true


  initialize: =>
    super

    # construct shell models accordingly
    @model.shells()

    # sync all metadata
    # TODO @model.shells().each (shell) => shell.metaData().sync()

    # keep all subviews in memory - perhaps in the future only keep p<c>n.
    @shellViews = @model.shells().map @initializeSubshellMediaView

    @initializeSubshellEvents()

    # initialize the currently selected view
    @currentIndex = 0

    @initializeControlsView()


  initializeSubshellMediaView: (shellModel) =>
    view = new shellModel.module.MediaView
      # TODO: should be passing `eventhub: @` and selectively forwarding
      # events to @eventhub
      eventhub: @eventhub
      model: shellModel

    view.on 'all', =>
      arguments[0] = 'Subshell:' + arguments[0]
      @trigger.apply(@, arguments)

    view


  initializeSubshellEvents: =>

    @on 'Subshell:Media:Progress', (view, elapsed, total) =>
      # add the duration so far
      viewsBefore = _.map _.range(@currentIndex), @shellView
      elapsed += @duration viewsBefore
      @trigger 'Media:Progress', @, elapsed, @duration()

    @on 'Subshell:Media:DidEnd', =>
      # if last shell, we end!
      if (@currentIndex + 1) is @shellViews.length
        @setMediaState 'end'

      else if @options.autoAdvanceOnEnd
        @showNext()

    @on 'Subshell:Media:DidReady', (view) =>
      # process iff this is the view currently showing
      if view isnt @shellView()
        return

      # if we're still initializing, we're good to go when first shell is ready
      if @isIniting() and @options.readyOnFirstShellReady
        @setMediaState 'ready'

      # if this just loaded, we're playing, and we want it to keep playing
      if @isPlaying() and @options.playOnChangeShell
        view.play()

    @on 'Subshell:Media:DidPlay', =>
      unless @_switchingShell or @isPlaying()
        @play()

    @on 'Subshell:Media:DidPause', =>
      unless @_switchingShell or @isPaused()
        @pause()




  initializeControlsView: =>
    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Previous', 'Next']
      eventhub: @eventhub

    @controlsView.on 'PreviousControl:Click', @showPrevious
    @controlsView.on 'ListControl:Click', @onTogglePlaylist
    @controlsView.on 'NextControl:Click', @showNext


  remove: =>
    @controlsView.off 'PreviousControl:Click', @showPrevious
    @controlsView.off 'ListControl:Click', @onTogglePlaylist
    @controlsView.off 'NextControl:Click', @showNext
    super


  render: =>
    super
    @$el.empty()
    if @options.showFirstSubshellOnRender
      @showView @currentIndex
    @


  onMediaDidPlay: =>
    @shellView()?.play()


  onMediaDidPause: =>
    @shellView()?.pause()


  duration: (shellViews) =>
    shellViews ?= @shellViews
    sum = (total, view) => total + view.duration()
    _.reduce shellViews, sum, 0


  shellView: (index) =>
    index ?= @currentIndex
    @shellViews[index]


  switchShell: (index) =>
    unless 0 <= index < @shellViews.length
      return

    @_switchingShell = true
    @hideView()
    @currentIndex = index
    view = @showView()

    if @isPlaying() and not view.isPlaying() and view.canPlay()
      view.play()

    delete @_switchingShell


  hideView: (index) =>
    view = @shellView index
    unless view
      return

    #view?.remove()

    # TODO: events are being bound with listenTo, and do not get rebound on
    # rerenders following a remove() call. This is a quick fix until they get
    # refactored.
    view.$el.addClass 'hidden'
    view.pause()

    # remove view.controlView
    if @options.showSubshellControls
      controlsIndex = _.indexOf @controlsView.buttons, view.controlsView
      if controlsIndex >= 0
        @controlsView.buttons.splice controlsIndex, 1
        @controlsView.softRender()

    # remove view.summaryView
    if @options.showSubshellSummary
      view.summaryView.$el.addClass 'hidden'

    view


  showView: (index) =>
    view = @shellView index
    unless view
      return

    # TODO: temporary fix - partner of above
    view.$el.removeClass 'hidden'
    unless view.el.parentNode is @el
      @$el.append view.render().el

    if @options.showSubshellSummary
      view.summaryView.$el.removeClass 'hidden'
      @summaryView.$el.append view.summaryView.render().el

    if @options.showSubshellControls
      # add view.controlsView
      @controlsView.buttons.push view.controlsView
      @controlsView.render()

    view


  showPrevious: =>
    unless @options.playOnChangeShell
      @pause()
    @switchShell @currentIndex - 1

  showNext: =>
    unless @options.playOnChangeShell
      @pause()
    @switchShell @currentIndex + 1



# uniform view to edit shell data.
class CollectionShell.RemixView extends Shell.RemixView

  className: @classNameExtend 'collection-shell'



acorn.registerShellModule CollectionShell
