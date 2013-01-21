goog.provide 'acorn.MediaInterface'


###
# MediaInterface

acorn's MediaInterface is a generic interface for all sorts of different
kinds of media. It abstracts the main functionality of embedded wbe media.

## States

Media can be in one of the following states:
1. initing - the media is getting ready to be in a playable state
2. ready - the media is done initing but has not started playing
3. playing - the media experience is under way
4. paused - the media experience is paused
5. ended - the media has finished playing (it can be restarted)

The state transitions possible are:
  1 -> 2
  2 -> 3
  3 -> 4
  4 -> 3
  3 -> 5
  5 -> 3

For all of these states, the media interface implements a method that triggers
three events:
* `:Will<state change>` is called right before state transition (WillPlay)
* `:<state change>` is called to perform the state transition (Play)
* `:Did<state change>` is called right after the state transition (DidPlay)

These three methods also trigger corresponding events (e.g. `Media:onReady`).

This is certainly a lot of methods, but they provide ample flexibility to
implement a wide variety of media behavior. Media implementations should
override the `on(Will|Did|)<state change>` methods, or listen to the triggered
events. The main `<state change>` methods (e.g. `play()`) should not be
overridden.

###

class acorn.MediaInterface

  # mixin Backbone.Events (not a class)
  _.extend @prototype, Backbone.Events


  wireMediaEvents: (options) =>

    if options.playOnReady
      @on 'Media:DidReady', @play


  # State transitions.
  # do not override these, call them directly, listen on the events


  init: =>
    @trigger 'Media:WillInit', @
    @trigger 'Media:Init', @
    @state = 'init'
    @trigger 'Media:DidInit', @


  ready: =>
    @trigger 'Media:WillReady', @
    @trigger 'Media:Ready', @
    @state = 'ready'
    @trigger 'Media:DidReady', @


  play: =>
    @trigger 'Media:WillPlay', @
    @trigger 'Media:Play', @
    @state = 'play'
    @trigger 'Media:DidPlay', @


  pause: =>
    @trigger 'Media:WillPause', @
    @trigger 'Media:Pause', @
    @state = 'pause'
    @trigger 'Media:DidPause', @


  end: =>
    @trigger 'Media:WillEnd', @
    @trigger 'Media:End', @
    @state = 'end'
    @trigger 'Media:DidEnd', @


  # State checks -- returns true if media is in a particular state
  isInStateInit: => @state is 'init'
  isInStateReady: => @state is 'ready'
  isInStatePlay: => @state is 'play'
  isInStatePause: => @state is 'pause'
  isInStateEnd: => @state is 'end'
  ended: => @isInStateEnd()


  # Seek to/return playback offset.
  seekOffset: => 0
  seek: (offset) =>


  # Returns the view's total duration in seconds
  duration: => 0


  # Sets the media view's volume.
  volume: =>
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
