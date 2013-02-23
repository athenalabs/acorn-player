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

  viewOptions = ->
    model: new Model {shellid: CollectionShell.id}
    eventhub: _.extend {}, Backbone.Events

  it 'should be part of acorn.shells', ->
    expect(CollectionShell).toBeDefined()

  acorn.util.test.describeShellModule CollectionShell, ->

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

    describe 'MediaView::correctedIndex', ->

      it 'should cycle index if options.shellsCycle', ->
        model = new Model shells: [{shellid: Shell.id}, {shellid: Shell.id}]
        view = new CollectionShell.MediaView model: model, shellsCycle: true
        _.each [-1, 0, 1, 2, 3, 6, 10], (index) ->
          expect(view.correctedIndex index).toBe ((index + 2) % 2)

      it 'should not cycle index unless options.shellsCycle', ->
        model = new Model shells: [{shellid: Shell.id}, {shellid: Shell.id}]
        view = new CollectionShell.MediaView model: model, shellsCycle: false
        _.each [-1, 0, 1, 2, 3, 6, 10], (index) ->
          expect(view.correctedIndex index).toBe index


  describe 'CollectionShell.RemixView', ->

    describe 'RemixView: default thumbnail', ->

      it 'should use its first shell\'s thumbnail as its default thumbnail', ->
        view = new RemixView viewOptions()
        fakeShells = first: -> thumbnail: -> 'fake thumbnail'
        spyOn(view.model, 'shells').andReturn fakeShells

        expect(view.model.shells).not.toHaveBeenCalled()
        expect(view.defaultAttributes().thumbnail).toBe 'fake thumbnail'
        expect(view.model.shells).toHaveBeenCalled()

      it 'should call _updateAttributesWithDefaults when shells change', ->
        spyOn RemixView::, '_updateAttributesWithDefaults'
        view = new RemixView viewOptions()

        expect(RemixView::_updateAttributesWithDefaults.callCount).toBe 1
        view.model.trigger 'change:shells'
        expect(RemixView::_updateAttributesWithDefaults.callCount).toBe 2
