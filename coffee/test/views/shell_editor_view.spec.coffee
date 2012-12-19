goog.provide 'acorn.specs.player.ShellEditorView'

goog.require 'acorn.player.ShellEditorView'
goog.require 'acorn.shells.TextShell'
goog.require 'acorn.shells.EmptyShell'

describe 'acorn.player.ShellEditorView', ->
  EventSpy = athena.lib.util.test.EventSpy
  describeView = athena.lib.util.test.describeView
  describeSubview = athena.lib.util.test.describeSubview

  Shell = acorn.shells.Shell
  TextShell = acorn.shells.TextShell
  EmptyShell = acorn.shells.EmptyShell
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

    it 'should hide the ShellOptionsView when there are < 2 shells', ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2
      expect(view.shellOptionsView.$el.css 'display').toBe 'block'

      view.removeShell view.model.shells().models[0]
      expect(view.remixerViews.length).toBe 1
      expect(view.shellOptionsView.$el.css 'display').toBe 'none'

    it 'should show the ShellOptionsView when there are > 1 shells', ->
      view = new ShellEditorView options
      view.render()
      expect(view.remixerViews.length).toBe 2
      expect(view.shellOptionsView.$el.css 'display').toBe 'block'

      view.removeShell view.model.shells().models[0]
      expect(view.remixerViews.length).toBe 1
      expect(view.shellOptionsView.$el.css 'display').toBe 'none'

      _.each _.range(10), (i) =>
        view.addShell new Shell.Model
        expect(view.remixerViews.length).toBe 2 + i
        expect(view.shellOptionsView.$el.css 'display').toBe 'block'

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

  describe 'ShellEditor Duplicate Shell', ->

    it 'should be triggered by a Remixer:Duplicate event', ->
      view = new ShellEditorView options
      view.render()
      remixer = view.remixerViews[0]

      spy = spyOn(view, 'addShell').andCallThrough()
      remixer.trigger 'Remixer:Duplicate'
      expect(spy).toHaveBeenCalled()

    it 'should add a clone of the remixerView\'s shell', ->
      view = new ShellEditorView options
      view.render()
      remixer = view.remixerViews[0]

      spy = spyOn(view, 'addShell').andCallThrough()
      remixer.trigger 'Remixer:Duplicate'

      shell = spy.mostRecentCall.args[0]
      expect(shell instanceof Shell.Model).toBe true
      expect(shell.attributes).toEqual remixer.model.attributes

  describe 'ShellEditor Delete Shell', ->

    it 'should be triggered by a Remixer:Delete event', ->
      view = new ShellEditorView options
      view.render()
      remixer = view.remixerViews[0]

      spy = spyOn(view, 'removeShell').andCallThrough()
      remixer.trigger 'Remixer:Delete'
      expect(spy).toHaveBeenCalled()

    it 'should remove the remixerView\'s shell', ->
      view = new ShellEditorView options
      view.render()
      remixer = view.remixerViews[0]

      spy = spyOn(view, 'removeShell').andCallThrough()
      remixer.trigger 'Remixer:Delete'
      expect(spy).toHaveBeenCalledWith remixer.model



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
