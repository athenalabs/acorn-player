goog.provide 'acorn.specs.shells.CollectionShell'

goog.require 'acorn.shells.CollectionShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.CollectionShell', ->
  derives = athena.lib.util.derives
  EventSpy = athena.lib.util.test.EventSpy

  Shell = acorn.shells.Shell
  CollectionShell = acorn.shells.CollectionShell

  Model = CollectionShell.Model
  MediaView = CollectionShell.MediaView
  RemixView = CollectionShell.RemixView

  modelOptions = ->
    shellid: CollectionShell.id
    shells: [
      {shellid: Shell.id}
      {shellid: Shell.id}
    ]

  viewOptions = (opts = {}) ->
    _.defaults opts,
      model: new Model modelOptions()
      eventhub: _.extend {}, Backbone.Events

  it 'should be part of acorn.shells', ->
    expect(CollectionShell).toBeDefined()

  acorn.util.test.describeShellModule CollectionShell, modelOptions(), ->

    test.describeDefaults CollectionShell.MediaView, {
      playOnReady: true
      readyOnRender: false
      readyOnFirstShellReady: true
      showFirstSubshellOnRender: true
      playOnChangeShell: true
      showSubshellControls: true
      showSubshellSummary: true
      autoAdvanceOnEnd: true
      shellsCycle: false
    }, viewOptions()


  describe 'CollectionShell.Model', ->

    describe 'Model::shells', ->
      it 'should be a Backbone.Collection', ->
        m = new Model shellid: CollectionShell.id
        expect(m.shells() instanceof Backbone.Collection).toBe true

      it 'should be lazily constructed', ->
        m = new Model shellid: CollectionShell.id
        expect(m._shells).not.toBeDefined()
        m.shells()
        expect(m._shells).toBeDefined()

      it 'should be initialized with proper state', ->
        shells = [
          new Model().attributes
          new Model().attributes
        ]
        m = new Model shellid: CollectionShell.id, shells: shells
        c = m.shells()
        expect(c.models[0].attributes).toEqual shells[0]
        expect(c.models[1].attributes).toEqual shells[1]

      it 'adding shells should update internal state', ->
        m = new Model
        c = m.shells()

        m2 = new Model
        m3 = new Model

        c.add m2
        expect(c.models[0]).toBe m2
        expect(m.get 'shells').toEqual [m2.attributes]

        c.add m3
        expect(c.models[1]).toBe m3
        expect(m.get 'shells').toEqual [m2.attributes, m3.attributes]

      it 'adding shells with indices should work', ->
        m = new Model
        c = m.shells()

        m2 = new Model
        m3 = new Model
        m4 = new Model

        c.add m2, {at: 0}
        expect(c.models[0]).toBe m2
        expect(m.get 'shells').toEqual [m2.attributes]

        c.add m3, {at: 0}
        expect(c.models[0]).toBe m3
        expect(m.get 'shells').toEqual [m3.attributes, m2.attributes]

        c.add m4, {at: 1}
        expect(c.models[1]).toBe m4
        expect(m.get 'shells').toEqual \
          [m3.attributes, m4.attributes, m2.attributes]

      it 'removing shells should update internal state', ->
        shells = [new Model().attributes, new Model().attributes]
        m = new Model shells: shells
        c = m.shells()

        m2 = c.models[0]
        m3 = c.models[1]

        expect(m2.attributes).toEqual shells[0]
        expect(m3.attributes).toEqual shells[1]
        expect(m.get 'shells').toEqual [m2.attributes, m3.attributes]

        c.remove(m2)
        expect(m.get 'shells').toEqual [m3.attributes]

        c.remove(m3)
        expect(m.get 'shells').toEqual []


      it 'removing and adding shells successively should work', ->

        todo = [
          {add: {shellid: Shell.id}},
          {add: {shellid: EmptyShell.id}},
          {remove: 1},
          {add: {shellid: Shell.id}},
          {add: {shellid: CollectionShell.id}},
          {add: {shellid: Shell.id}},
          {remove: 2},
          {remove: 2},
          {remove: 0},
          {remove: 0}
        ]

        m = new Model shellid: CollectionShell.id
        shells = []
        check = ->
          expect(m.get 'shells').toEqual shells
          data = m.shells().map (shell) -> shell.attributes
          expect(data).toEqual shells

        _.each todo, (action, shellOrIndex) =>
          if action is 'add'
            shells.push shellOrIndex
            m.shells().add shellOrIndex
          else
            shells.splice(shellOrIndex, 0)
            m.shells().remove m.shells().models[shellOrIndex]
          check()


      it 'should trigger change events on adding', ->
        m = new Model
        spy1 = new EventSpy m, 'change'
        spy2 = new EventSpy m, 'change:shells'

        c = m.shells()
        c.add new Model
        expect(spy1.triggered).toBe true
        expect(spy2.triggered).toBe true

      it 'should trigger change events on removing', ->
        m = new Model shells: [{shellid: Shell.id}]
        spy1 = new EventSpy m, 'change'
        spy2 = new EventSpy m, 'change:shells'

        c = m.shells()
        c.remove c.models[0]
        expect(spy1.triggered).toBe true
        expect(spy2.triggered).toBe true

      it 'should trigger change events on reseting', ->
        m = new Model shells: [{shellid: Shell.id}]
        spy1 = new EventSpy m, 'change'
        spy2 = new EventSpy m, 'change:shells'

        c = m.shells()
        c.reset [new Model, new Model, new Model]
        expect(spy1.triggered).toBe true
        expect(spy2.triggered).toBe true


  describe 'CollectionShell.MediaView', ->

    describe 'MediaView::switchShell', ->

      it 'should be a function', ->
        expect(typeof MediaView::switchShell).toBe 'function'

      it 'should call `hideView`', ->
        view = new MediaView viewOptions()
        spyOn view, 'hideView'

        expect(view.hideView).not.toHaveBeenCalled()
        view.switchShell 0
        expect(view.hideView).toHaveBeenCalled()

      it 'should set currentIndex to index', ->
        view = new MediaView viewOptions()
        view.currentIndex = 5

        expect(view.currentIndex).toBe 5
        view.switchShell 0
        expect(view.currentIndex).toBe 0

      it 'should call `showView`', ->
        view = new MediaView viewOptions()
        spyOn view, 'showView'

        expect(view.showView).not.toHaveBeenCalled()
        view.switchShell 0
        expect(view.showView).toHaveBeenCalled()

      it 'should call `showView` with index', ->
        view = new MediaView viewOptions()
        spyOn view, 'showView'

        expect(view.showView).not.toHaveBeenCalled()
        view.switchShell 0
        expect(view.showView).toHaveBeenCalled()
        expect(view.showView.mostRecentCall.args[0]).toBe 0

      it 'should call `_updateProgressBar`', ->
        view = new MediaView viewOptions()
        spyOn view, '_updateProgressBar'

        expect(view._updateProgressBar).not.toHaveBeenCalled()
        view.switchShell 0
        expect(view._updateProgressBar).toHaveBeenCalled()


    describe 'MediaView::showView', ->

      it 'should be a function', ->
        expect(typeof MediaView::showView).toBe 'function'

      it 'should access shellView at given index', ->
        view = new MediaView viewOptions()
        spyOn(view, 'shellView').andCallThrough()

        expect(view.shellView).not.toHaveBeenCalled()
        view.showView 0
        expect(view.shellView).toHaveBeenCalled()
        expect(view.shellView).toHaveBeenCalledWith 0

      it 'should return shellView at given index', ->
        view = new MediaView viewOptions()
        spyOn(view, 'shellView').andCallThrough()

        expect(view.shellView).not.toHaveBeenCalled()
        shellView = view.showView 0
        expect(view.shellView).toHaveBeenCalled()
        expect(view.shellView).toHaveBeenCalledWith 0
        expect(shellView).toBe view.shellView 0

      it 'should append shellView at given index to $el', ->
        view = new MediaView viewOptions()
        view.render()
        shellView = view.shellView 0
        shellView.$el.remove()

        expect(shellView.el.parentNode).not.toBe view.el
        view.showView 0
        expect(shellView.el.parentNode).toBe view.el

      it 'should show the shellView at given index', ->
        view = new MediaView viewOptions()
        view.render()
        shellView = view.shellView 0
        shellView.$el.addClass 'hidden'

        expect(shellView.$el.hasClass 'hidden').toBe true
        view.showView 0
        expect(shellView.$el.hasClass 'hidden').toBe false


    describe 'MediaView::hideView', ->

      it 'should be a function', ->
        expect(typeof MediaView::hideView).toBe 'function'

      it 'should access shellView at given index', ->
        view = new MediaView viewOptions()
        spyOn(view, 'shellView').andCallThrough()

        expect(view.shellView).not.toHaveBeenCalled()
        view.hideView 0
        expect(view.shellView).toHaveBeenCalled()
        expect(view.shellView).toHaveBeenCalledWith 0

      it 'should return shellView at given index', ->
        view = new MediaView viewOptions()
        spyOn(view, 'shellView').andCallThrough()

        expect(view.shellView).not.toHaveBeenCalled()
        shellView = view.hideView 0
        expect(view.shellView).toHaveBeenCalled()
        expect(view.shellView).toHaveBeenCalledWith 0
        expect(shellView).toBe view.shellView 0

      it 'should hide the shellView at given index', ->
        view = new MediaView viewOptions()
        view.render()
        shellView = view.shellView 0
        shellView.$el.removeClass 'hidden'

        expect(shellView.$el.hasClass 'hidden').toBe false
        view.hideView 0
        expect(shellView.$el.hasClass 'hidden').toBe true

      it 'should pause the shellView at given index', ->
        view = new MediaView viewOptions()
        view.render()
        shellView = view.shellView 0
        spyOn shellView, 'pause'

        expect(shellView.pause).not.toHaveBeenCalled()
        view.hideView 0
        expect(shellView.pause).toHaveBeenCalled()


    describe 'MediaView::showPrevious', ->

      it 'should be a function', ->
        expect(typeof MediaView::showPrevious).toBe 'function'

      it 'should pause playback if playOnChangeShell is false', ->
        view = new MediaView viewOptions playOnChangeShell: false
        spyOn view, 'pause'

        expect(view.pause).not.toHaveBeenCalled()
        view.showPrevious()
        expect(view.pause).toHaveBeenCalled()

      it 'should not pause playback if playOnChangeShell is true', ->
        view = new MediaView viewOptions playOnChangeShell: true
        spyOn view, 'pause'

        expect(view.pause).not.toHaveBeenCalled()
        view.showPrevious()
        expect(view.pause).not.toHaveBeenCalled()

      it 'should get index of previous shell', ->
        view = new MediaView viewOptions playOnChangeShell: true
        spyOn(view, 'correctedIndex').andReturn 0
        view.currentIndex = 8

        expect(view.correctedIndex).not.toHaveBeenCalled()
        view.showPrevious()
        expect(view.correctedIndex).toHaveBeenCalled()
        expect(view.correctedIndex).toHaveBeenCalledWith 7

      it 'should call switchShell with index of previous shell', ->
        view = new MediaView viewOptions playOnChangeShell: true
        spyOn(view, 'correctedIndex').andReturn 'fakeIndex'
        spyOn view, 'switchShell'

        expect(view.switchShell).not.toHaveBeenCalled()
        view.showPrevious()
        expect(view.switchShell).toHaveBeenCalled()
        expect(view.switchShell.mostRecentCall.args[0]).toBe 'fakeIndex'


    describe 'MediaView::showNext', ->

      it 'should be a function', ->
        expect(typeof MediaView::showNext).toBe 'function'

      it 'should pause playback if playOnChangeShell is false', ->
        view = new MediaView viewOptions playOnChangeShell: false
        spyOn view, 'pause'

        expect(view.pause).not.toHaveBeenCalled()
        view.showNext()
        expect(view.pause).toHaveBeenCalled()

      it 'should not pause playback if playOnChangeShell is true', ->
        view = new MediaView viewOptions playOnChangeShell: true
        spyOn view, 'pause'

        expect(view.pause).not.toHaveBeenCalled()
        view.showNext()
        expect(view.pause).not.toHaveBeenCalled()

      it 'should get index of next shell', ->
        view = new MediaView viewOptions playOnChangeShell: true
        spyOn(view, 'correctedIndex').andReturn 0
        view.currentIndex = 8

        expect(view.correctedIndex).not.toHaveBeenCalled()
        view.showNext()
        expect(view.correctedIndex).toHaveBeenCalled()
        expect(view.correctedIndex).toHaveBeenCalledWith 9

      it 'should call switchShell with index of next shell', ->
        view = new MediaView viewOptions playOnChangeShell: true
        spyOn(view, 'correctedIndex').andReturn 'fakeIndex'
        spyOn view, 'switchShell'

        expect(view.switchShell).not.toHaveBeenCalled()
        view.showNext()
        expect(view.switchShell).toHaveBeenCalled()
        expect(view.switchShell.mostRecentCall.args[0]).toBe 'fakeIndex'


    describe 'MediaView::correctedIndex', ->

      it 'should cycle index if options.shellsCycle', ->
        view = new MediaView viewOptions shellsCycle: true
        _.each [-1, 0, 1, 2, 3, 6, 10], (index) ->
          expect(view.correctedIndex index).toBe ((index + 2) % 2)

      it 'should not cycle index unless options.shellsCycle', ->
        view = new MediaView viewOptions shellsCycle: false
        _.each [-1, 0, 1, 2, 3, 6, 10], (index) ->
          expect(view.correctedIndex index).toBe index


    describe 'MediaView::progressBarState', ->

      it 'should return progressBarState of active subshell', ->
        view = new MediaView viewOptions()
        subshellState = jasmine.createSpy()
        spyOn(view, 'shellView').andReturn
          progressBarState: subshellState

        expect(subshellState).not.toHaveBeenCalled()
        view.progressBarState()
        expect(subshellState).toHaveBeenCalled()


    describe 'MediaView::_progressBarDidProgress', ->

      it 'should forward "ProgressBar:DidProgress" event to active subshell', ->
        view = new MediaView viewOptions()
        subshellTrigger = jasmine.createSpy()
        spyOn(view, 'shellView').andReturn
          trigger: subshellTrigger

        expect(subshellTrigger).not.toHaveBeenCalled()
        view._onProgressBarDidProgress 'fakeArg1', 'fakeArg2'
        expect(subshellTrigger).toHaveBeenCalled()
        args = subshellTrigger.mostRecentCall.args
        expect(args[0]).toBe 'ProgressBar:DidProgress'
        expect(args[1]).toBe 'fakeArg1'
        expect(args[2]).toBe 'fakeArg2'


    describe 'MediaView: events', ->

      it 'should call `_updateProgressBar` on "Subshell:Shell:UpdateProgress' +
          'Bar"', ->
        spyOn MediaView::, '_updateProgressBar'
        view = new MediaView viewOptions()

        expect(MediaView::_updateProgressBar).not.toHaveBeenCalled()
        view.trigger 'Subshell:Shell:UpdateProgressBar'
        expect(MediaView::_updateProgressBar).toHaveBeenCalled()


  describe 'CollectionShell.RemixView', ->

    describe 'RemixView::defaultAttributes', ->

      it 'should default title to a message about its collection', ->
        rv = new RemixView viewOptions()
        expect(rv.model.title()).toBe "Collection with 2 items"

        fakeShells = new Backbone.Collection()
        for i in [0..2]
          fakeShell = new Backbone.Model()
          fakeShell.thumbnail = -> 'thumbnails.com/fake.jpg'
          fakeShells.add fakeShell

        spyOn(rv.model, 'shells').andReturn fakeShells
        rv._updateAttributesWithDefaults()
        expect(rv.model.title()).toBe "Collection with 3 items"

      it 'should default thumbnail to the thumbnail of its first subshell', ->
        rv = new RemixView viewOptions()

        fakeShells = new Backbone.Collection()
        for i in [0..2]
          fakeShell = new Backbone.Model()
          fakeShell.thumbnail = -> 'thumbnails.com/fake.jpg'
          fakeShells.add fakeShell

        spyOn(rv.model, 'shells').andReturn fakeShells
        rv._updateAttributesWithDefaults()
        expect(rv.model.thumbnail()).toBe 'thumbnails.com/fake.jpg'


    it 'should call _updateAttributesWithDefaults when shells change', ->
      spyOn RemixView::, '_updateAttributesWithDefaults'
      view = new RemixView viewOptions()

      expect(RemixView::_updateAttributesWithDefaults.callCount).toBe 1
      view.model.trigger 'change:shells'
      expect(RemixView::_updateAttributesWithDefaults.callCount).toBe 2
