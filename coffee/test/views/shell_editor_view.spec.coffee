goog.provide 'acorn.specs.player.ShellEditorView'

goog.require 'acorn.player.ShellEditorView'
goog.require 'acorn.shells.TextShell'
goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.shells.GalleryShell'
goog.require 'acorn.shells.CollectionShell'

describe 'acorn.player.ShellEditorView', ->
  test = athena.lib.util.test
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  Shell = acorn.shells.Shell
  TextShell = acorn.shells.TextShell
  EmptyShell = acorn.shells.EmptyShell
  GalleryShell = acorn.shells.GalleryShell
  CollectionShell = acorn.shells.CollectionShell
  ShellEditorView = acorn.player.ShellEditorView

  # model for EditorView contruction
  model = new TextShell.Model

  # options for EditorView contruction
  options = model: model


  it 'should be part of acorn.player', ->
    expect(ShellEditorView).toBeDefined()

  describeView ShellEditorView, athena.lib.View, options

  describe 'construction', ->

    it 'should wrap single-shells in a CollectionShell.Model', ->
      view = new ShellEditorView options
      expect(view.model instanceof CollectionShell.Model).toBe true
      expect(view.model.shells().models[0]).toBe model

    it 'should add an EmptyShell to the collectionShell', ->
      view = new ShellEditorView options
      coll = view.model.shells()
      expect(coll.models[1] instanceof EmptyShell.Model).toBe true

    it 'should add an EmptyShell to a provided collectionShell', ->
      collection = new acorn.shells.CollectionShell.Model
        shellid: 'acorn.CollectionShell'
      collection.shells().add model

      view = new ShellEditorView model: collection
      coll = view.model.shells()
      expect(coll.models[1] instanceof EmptyShell.Model).toBe true

    it 'should not mess with CollectionShell with EmptyShells', ->
      collection = new acorn.shells.CollectionShell.Model
        shellid: 'acorn.CollectionShell'
      collection.shells().add model

      empty = new acorn.shells.EmptyShell.Model
        shellid: 'acorn.EmptyShell'
      collection.shells().add empty

      view = new ShellEditorView model: collection
      expect(view.model).toBe collection
      expect(view.model.shells().models[0]).toBe model
      expect(view.model.shells().models[1]).toBe empty

  describe 'finalized shell retrieval', ->

    it 'should return single shells', ->
      model = new TextShell.Model
      view = new ShellEditorView model: model
      shell = view.shell()
      expect(shell instanceof TextShell.Model).toBe true
      expect(shell.attributes).toEqual model.attributes

    it 'should return a collection shell when it has multiple shells', ->
      models = [new TextShell.Model, new CollectionShell.Model]
      view = new ShellEditorView
      view.addShell models[0]
      view.addShell models[1]

      shell = view.shell()
      expect(shell instanceof CollectionShell.Model).toBe true
      expect(shell.shells().models[0].attributes).toEqual models[0].attributes
      expect(shell.shells().models[1].attributes).toEqual models[1].attributes



  describeSubview
    View: ShellEditorView
    Subview: acorn.player.ShellOptionsView
    subviewAttr: 'shellOptionsView'
    viewOptions: options


  describe 'ShellEditorView::remixerViews subviews', ->
    # below, tests marked `(added)` add another shell after construction
    # and even after rendering, to ensure the suviews work well given
    # shell additions.

    anotherShell = acorn.shellWithData shellid: 'acorn.TextShell'

    it 'should be defined on init', ->
      view = new ShellEditorView options
      expect(view.remixerViews).toBeDefined()
      expect(view.remixerViews.length).toBe 2 # +1 empty shell

    it "should be instancesof RemixerView", ->
      view = new ShellEditorView options
      expect(view.remixerViews.length).toBe 2 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv instanceof acorn.player.RemixerView).toBe true

    it "should be instancesof RemixerView (added)", ->
      view = new ShellEditorView options
      view.addShell anotherShell
      expect(view.remixerViews.length).toBe 3 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv instanceof acorn.player.RemixerView).toBe true

    it 'should not be rendering initially', ->
      view = new ShellEditorView options
      expect(view.remixerViews.length).toBe 2 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv.rendering).toBe false

    it 'should not be rendering initially (added)', ->
      view = new ShellEditorView options
      view.addShell anotherShell
      expect(view.remixerViews.length).toBe 3 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv.rendering).toBe false

    it "should be rendering with ShellEditorView", ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv.rendering).toBe true

    it "should be rendering with ShellEditorView (added)", ->
      view = new ShellEditorView options
      view.render()
      view.addShell anotherShell
      expect(view.remixerViews.length).toBe 3 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv.rendering).toBe true

    it "should be DOM descendants of the ShellEditorView", ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv.el.parentNode.parentNode).toBe view.el

    it "should be DOM descendants of the ShellEditorView (added)", ->
      view = new ShellEditorView options
      view.render()
      view.addShell anotherShell
      expect(view.remixerViews.length).toBe 3 # +1 empty shell
      _.map view.remixerViews, (rv) ->
        expect(rv.el.parentNode.parentNode).toBe view.el


  describe 'ShellEditorView::renderUpdates', ->

    it 'should have ShellOptionsView hidden with one non-empty shell', ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2
      expect(view.model.shells().models[0].module).not.toBe EmptyShell
      expect(view.model.shells().models[1].module).toBe EmptyShell
      expect(view.shellOptionsView.$el.hasClass 'hidden').toBe true

    it 'should hide the ShellOptionsView with < 2 non-empty shells', ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2
      expect(view.shellOptionsView.$el.hasClass 'hidden').toBe true

      _.each _.range(10), (i) =>
        view.addShell new TextShell.Model
        expect(view.remixerViews.length).toBe 3 + i
        expect(view.shellOptionsView.$el.hasClass 'hidden').toBe false

      _.each _.range(10), (i) =>
        view.removeShell view.model.shells().models[1]

      expect(view.remixerViews.length).toBe 2
      expect(view.shellOptionsView.$el.hasClass 'hidden').toBe true

    it 'should show the ShellOptionsView with > 1 non-empty shells', ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2
      expect(view.shellOptionsView.$el.hasClass 'hidden').toBe true

      _.each _.range(10), (i) =>
        view.addShell new Shell.Model
        expect(view.remixerViews.length).toBe 3 + i
        expect(view.shellOptionsView.$el.hasClass 'hidden').toBe false

    it 'should add an empty shell when going to 0 shells', ->
      view = new ShellEditorView options
      firstShell = -> view.model.shells().models[0]

      expect(view.remixerViews.length).toBe 2
      view.removeShell firstShell()
      expect(view.remixerViews.length).toBe 1

      view.removeShell firstShell()
      expect(view.remixerViews.length).toBe 1 # stay at 1
      expect(firstShell() instanceof EmptyShell.Model).toBe true

      view.removeShell firstShell()
      expect(view.remixerViews.length).toBe 1 # stay at 1
      expect(firstShell() instanceof EmptyShell.Model).toBe true

  describe 'ShellEditorView events', ->

    describe 'on ShellOptions:SwapShell', ->

      it 'should call swap the top level shell', ->
        view = new ShellEditorView options
        view.render()
        spyOn view, 'swapTopLevelShell'
        view.shellOptionsView.trigger 'ShellOptions:SwapShell', GalleryShell.id
        expect(view.swapTopLevelShell).toHaveBeenCalled()


      it 'should swap the shell seamlessly', ->
        view = new ShellEditorView options
        view.render()
        expect(view.model.shellid()).toBe CollectionShell.id
        models = _.clone view.model.shells().models

        view.shellOptionsView.trigger 'ShellOptions:SwapShell', GalleryShell.id
        expect(view.model.shellid()).toBe GalleryShell.id
        expect(view.shellOptionsView.model).toBe view.model
        expect(view.model.shells().models.length).toEqual models.length
        expect(view.model.shells().models[0]).toEqual models[0]


    describe 'on Remixer:Toolbar:Click:Duplicate', ->

      it 'should call add shell', ->
        view = new ShellEditorView options
        view.render()
        remixer = view.remixerViews[0]

        spy = spyOn(view, 'addShell').andCallThrough()
        remixer.trigger 'Remixer:Toolbar:Click:Duplicate', remixer
        expect(spy).toHaveBeenCalled()

      it 'should add a clone of the remixerView\'s shell', ->
        view = new ShellEditorView options
        view.render()
        remixer = view.remixerViews[0]

        spy = spyOn(view, 'addShell').andCallThrough()
        remixer.trigger 'Remixer:Toolbar:Click:Duplicate', remixer

        shell = spy.mostRecentCall.args[0]
        expect(shell instanceof Shell.Model).toBe true
        expect(shell.attributes).toEqual remixer.model.attributes

    describe 'on Remixer:Toolbar:Click:Delete', ->

      it 'should call remove shell', ->
        view = new ShellEditorView options
        view.render()
        remixer = view.remixerViews[0]

        spy = spyOn(view, 'removeShell').andCallThrough()
        remixer.trigger 'Remixer:Toolbar:Click:Delete', remixer
        expect(spy).toHaveBeenCalled()

      it 'should remove the remixerView\'s shell', ->
        view = new ShellEditorView options
        view.render()
        remixer = view.remixerViews[0]

        spy = spyOn(view, 'removeShell').andCallThrough()
        remixer.trigger 'Remixer:Toolbar:Click:Delete', remixer
        expect(spy).toHaveBeenCalledWith remixer.model

    describe 'on Remixer:SwapShell', ->

      it 'should call swapSubShell', ->
        oldShell = new acorn.shells.LinkShell.Model
        newShell = new acorn.shells.ImageLinkShell.Model
        view = new ShellEditorView model: oldShell
        view.render()
        remixer = view.remixerViews[0]

        spy = spyOn(view, 'swapSubShell').andCallThrough()
        remixer.trigger 'Remixer:SwapShell', remixer, oldShell, newShell
        expect(spy).toHaveBeenCalled()

      it 'should be triggered with a new, different shell', ->
        oldShell = new acorn.shells.LinkShell.Model
        newShell = new acorn.shells.ImageLinkShell.Model
        view = new ShellEditorView model: oldShell
        view.render()
        remixer = view.remixerViews[0]

        spy = spyOn(view, 'swapSubShell').andCallThrough()
        remixer.trigger 'Remixer:SwapShell', remixer, oldShell, newShell
        expect(spy).toHaveBeenCalledWith oldShell, newShell

      it 'should remove the old shell, and replace it with the new', ->
        oldShell = new acorn.shells.LinkShell.Model
        newShell = new acorn.shells.ImageLinkShell.Model
        view = new ShellEditorView model: oldShell
        view.render()
        remixer = view.remixerViews[0]

        expect(view.model.shells().models[0]).toBe oldShell
        expect(view.remixerViews[0].model).toBe oldShell

        remixer.swapShell newShell
        expect(view.model.shells().models[0]).toBe newShell
        expect(view.remixerViews[0].model).toBe newShell

      it 'should not change the remixerView (it changed already)', ->
        oldShell = new acorn.shells.LinkShell.Model
        newShell = new acorn.shells.ImageLinkShell.Model
        view = new ShellEditorView model: oldShell
        view.render()
        remixer = view.remixerViews[0]

        remixer.swapShell newShell
        expect(view.remixerViews[0]).toBe remixer


    describe 'on Remixer:LinkChanged', ->

      it 'should trigger ShellEditor:ShellsUpdated', ->
        oldShell = new acorn.shells.LinkShell.Model
        newShell = new acorn.shells.ImageLinkShell.Model
        view = new ShellEditorView model: oldShell
        view.render()
        remixer = view.remixerViews[0]

        spy = new test.EventSpy view, 'ShellEditor:ShellsUpdated'
        remixer.trigger 'Remixer:LinkChanged', remixer, 'http://foo.com'
        expect(spy.triggered).toBe true


    describe 'ShellEditor:Thumbnail:Change', ->

      it 'should be triggered initially', ->
        hub = new athena.lib.View
        shell = new acorn.shells.LinkShell.Model
        view = new ShellEditorView model: shell, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'
        view.render()
        expect(spy.triggerCount).toBe 1

      it 'should be triggered initially with proper thumbnail', ->
        hub = new athena.lib.View
        shell = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        view = new ShellEditorView model: shell, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'
        view.render()
        expect(spy.arguments[0][0]).toBe shell.thumbnail()
        expect(spy.arguments[0][0]).toBe 'foo.png'

      it 'should be triggered when thumbnail changes (swapping shells)', ->
        hub = new athena.lib.View
        oldShell = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        newShell = new acorn.shells.ImageLinkShell.Model thumbnail: 'bar.png'
        view = new ShellEditorView model: oldShell, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        expect(spy.arguments[0][0]).toBe 'foo.png'
        view.swapSubShell oldShell, newShell
        expect(spy.triggerCount).toBe 2
        expect(spy.arguments[1][0]).toBe 'bar.png'

      it 'should NOT be triggered w/o thumbnail changes (swapping shells)', ->
        hub = new athena.lib.View
        oldShell = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        newShell = new acorn.shells.ImageLinkShell.Model thumbnail: 'foo.png'
        view = new ShellEditorView model: oldShell, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        view.swapSubShell oldShell, newShell
        expect(spy.triggerCount).toBe 1

      it 'should be triggered on adding shell as first (w. change)', ->
        hub = new athena.lib.View
        shell1 = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        shell2 = new acorn.shells.ImageLinkShell.Model thumbnail: 'bar.png'
        view = new ShellEditorView model: shell1, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        expect(spy.arguments[0][0]).toBe 'foo.png'
        view.addShell shell2, 0
        expect(spy.triggerCount).toBe 2
        expect(spy.arguments[1][0]).toBe 'bar.png'

      it 'should NOT be triggered on adding shell as first (wo. change)', ->
        hub = new athena.lib.View
        shell1 = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        shell2 = new acorn.shells.ImageLinkShell.Model thumbnail: 'foo.png'
        view = new ShellEditorView model: shell1, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        view.addShell shell2, 0
        expect(spy.triggerCount).toBe 1

      it 'should NOT be triggered on adding shells after first w. change', ->
        hub = new athena.lib.View
        shell1 = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        shell2 = new acorn.shells.ImageLinkShell.Model thumbnail: 'bar.png'
        view = new ShellEditorView model: shell1, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        view.addShell shell2
        expect(spy.triggerCount).toBe 1

      it 'should NOT be triggered on adding shells after first wo. change', ->
        hub = new athena.lib.View
        shell1 = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        shell2 = new acorn.shells.ImageLinkShell.Model thumbnail: 'foo.png'
        view = new ShellEditorView model: shell1, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        view.addShell shell2
        expect(spy.triggerCount).toBe 1

      it 'should be triggered upon removing first shell w. change', ->
        hub = new athena.lib.View
        shell1 = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        shell2 = new acorn.shells.ImageLinkShell.Model thumbnail: 'bar.png'
        view = new ShellEditorView model: shell1, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        view.addShell shell2
        expect(spy.triggerCount).toBe 1
        expect(spy.arguments[0][0]).toBe 'foo.png'
        view.removeShell shell1
        expect(spy.triggerCount).toBe 2
        expect(spy.arguments[1][0]).toBe 'bar.png'

      it 'should NOT be triggered upon removing first shell wo. change', ->
        hub = new athena.lib.View
        shell1 = new acorn.shells.LinkShell.Model thumbnail: 'foo.png'
        shell2 = new acorn.shells.ImageLinkShell.Model thumbnail: 'foo.png'
        view = new ShellEditorView model: shell1, eventhub: hub
        spy = new test.EventSpy hub, 'ShellEditor:Thumbnail:Change'

        view.render()
        expect(spy.triggerCount).toBe 1
        view.addShell shell2
        expect(spy.triggerCount).toBe 1
        view.removeShell shell1
        expect(spy.triggerCount).toBe 1


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new ShellEditorView options
    view.$el.width 600
    view.$el.height 600
    view.render()
    $player.append view.el
