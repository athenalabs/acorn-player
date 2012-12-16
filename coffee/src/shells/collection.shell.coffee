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


# Render each subshell in sequence. Shows each shell individually, keeping
# track of the current shell (through currentView). Rendering of the media
# is left entirely to the specific subshell.
#
# It listens to the 'left', 'list', and 'right' events from the
# Player.ContentView to navigate.

class CollectionShell.ContentView extends Shell.ContentView

  className: @classNameExtend 'collection-shell'

  initialize: =>
    super

    # construct shell models accordingly
    @shellModels = _.map @model.get('shells'), acorn.shellWithData

    # sync all metadata
    # TODO _.each @shellModels, (shellModel) => shellModel.metaData().sync()

    # keep all subviews in memory - perhaps in the future only keep p<c>n.
    @shellViews = _.map @shellModels, (shellModel) =>
      view = new shellModel.module.ContentView eventhub: @eventhub
      # TODO view.on 'playback:ended', @onShellPlaybackEnded
      view

    # initialize the currently selected view
    @currentIndex = 0

    @eventhub.on 'controls:left', @showPrevious
    @eventhub.on 'controls:list', @onTogglePlaylist
    @eventhub.on 'controls:right', @showNext

  remove: =>
    @eventhub.off 'controls:left', @onShowPrevious
    @eventhub.off 'controls:list', @onTogglePlaylist
    @eventhub.off 'controls:right', @onShowNext
    super

  render: =>
    super
    @$el.empty()
    @showView @currentIndex
    @

  showView: (index) =>
    unless 0 <= index < @shellViews.length
      return

    view = @shellViews[@currentIndex]
    view?.remove()

    @currentIndex = index
    view = @shellViews
    @$el.append view.render().el
    # TODO update controls
    view

  showPrevious: => @showView @currentIndex - 1
  showNext: => @showView @currentIndex + 1


# uniform view to edit shell data.
class CollectionShell.RemixView extends Shell.RemixView

  className: @classNameExtend 'collection-shell'


acorn.registerShellModule CollectionShell
