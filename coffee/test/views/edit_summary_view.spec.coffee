goog.provide 'acorn.specs.player.EditSummaryView'
goog.require 'acorn.player.EditSummaryView'
goog.require 'acorn.shells.TextShell'

describe 'acorn.player.EditSummaryView', ->
  test = athena.lib.util.test

  EditSummaryView = acorn.player.EditSummaryView
  TextShell = acorn.shells.TextShell

  # model for EditorView contruction
  model = (opts = {}) -> new TextShell.Model _.defaults opts,
    title: 'Title of the Best Acorn Ever'
    description: 'Description of the Best Acorn Ever: this acorn is the
      absolute best acorn ever, \'tis true. Description of the Best Acorn Ever:
      this acorn is the absolute best acorn ever, \'tis true.'

  viewOptions = (opts = {}) ->
    _.defaults opts,
      model: model()
      eventhub: new Backbone.View


  it 'should be part of acorn.player', ->
    expect(EditSummaryView).toBeDefined()


  test.describeView EditSummaryView, acorn.player.SummaryView, viewOptions(), ->

    describe 'EditSummaryView::_markupDefaults', ->

      it 'should be a function', ->
        expect(typeof EditSummaryView::_markupDefaults).toBe 'function'

      it 'should add default class to title field when title is default', ->
        view = new EditSummaryView viewOptions()
        view.render()
        spyOn(view.model, 'defaultAttributes').andReturn
          title: 'fake title'
          description: 'fake description'
          thumbnail: 'fake thumbnail'

        title = view.$ '.title'
        title.removeClass 'default'
        title.val 'fake title'

        expect(title.hasClass 'default').toBe false
        view._markupDefaults()
        expect(title.hasClass 'default').toBe true

      it 'should remove default class from title field when title is not
          default', ->
        view = new EditSummaryView viewOptions()
        view.render()
        spyOn(view.model, 'defaultAttributes').andReturn
          title: 'fake title'
          description: 'fake description'
          thumbnail: 'fake thumbnail'

        title = view.$ '.title'
        title.addClass 'default'
        title.val 'other fake title'

        expect(title.hasClass 'default').toBe true
        view._markupDefaults()
        expect(title.hasClass 'default').toBe false

      it 'should add default class to description field when title is default',
          ->
        view = new EditSummaryView viewOptions()
        view.render()
        spyOn(view.model, 'defaultAttributes').andReturn
          title: 'fake title'
          description: 'fake description'
          thumbnail: 'fake thumbnail'

        description = view.$ '.description'
        description.removeClass 'default'
        description.val 'fake description'

        expect(description.hasClass 'default').toBe false
        view._markupDefaults()
        expect(description.hasClass 'default').toBe true

      it 'should remove default class from description field when title is not
          default', ->
        view = new EditSummaryView viewOptions()
        view.render()
        spyOn(view.model, 'defaultAttributes').andReturn
          title: 'fake title'
          description: 'fake description'
          thumbnail: 'fake thumbnail'

        description = view.$ '.description'
        description.addClass 'default'
        description.val 'other fake description'

        expect(description.hasClass 'default').toBe true
        view._markupDefaults()
        expect(description.hasClass 'default').toBe false

      it 'should add default class to thumbnail field when title is default', ->
        view = new EditSummaryView viewOptions()
        view.render()
        view.popoverView.toggle()
        spyOn(view.model, 'defaultAttributes').andReturn
          title: 'fake title'
          description: 'fake description'
          thumbnail: 'fake thumbnail'

        thumbnail = view.$ '#link'
        thumbnail.removeClass 'default'
        thumbnail.val 'fake thumbnail'

        expect(thumbnail.hasClass 'default').toBe false
        view._markupDefaults()
        expect(thumbnail.hasClass 'default').toBe true

      it 'should remove default class from thumbnail field when title is not
          default', ->
        view = new EditSummaryView viewOptions()
        view.render()
        view.popoverView.toggle()
        spyOn(view.model, 'defaultAttributes').andReturn
          title: 'fake title'
          description: 'fake description'
          thumbnail: 'fake thumbnail'

        thumbnail = view.$ '#link'
        thumbnail.addClass 'default'
        thumbnail.val 'other fake thumbnail'

        expect(thumbnail.hasClass 'default').toBe true
        view._markupDefaults()
        expect(thumbnail.hasClass 'default').toBe false

      it 'should be called on keyup in an input field', ->
        spyOn EditSummaryView::, '_markupDefaults'
        view = new EditSummaryView viewOptions()
        view.render()

        expect(EditSummaryView::_markupDefaults.calls.length).toBe 1
        view.$('input').keyup()
        expect(EditSummaryView::_markupDefaults.calls.length).toBe 2

      it 'should be called on keyup in a textarea', ->
        spyOn EditSummaryView::, '_markupDefaults'
        view = new EditSummaryView viewOptions()
        view.render()

        expect(EditSummaryView::_markupDefaults.calls.length).toBe 1
        view.$('textarea').keyup()
        expect(EditSummaryView::_markupDefaults.calls.length).toBe 2

      it 'should be called on thumbnail clicks', ->
        spyOn EditSummaryView::, '_markupDefaults'
        view = new EditSummaryView viewOptions()
        view.render()

        expect(EditSummaryView::_markupDefaults.calls.length).toBe 1
        view.$('.thumbnail-view').click()
        expect(EditSummaryView::_markupDefaults.calls.length).toBe 2

      it 'should be called when data is rendered', ->
        view = new EditSummaryView viewOptions()
        view.render()
        spyOn view, '_markupDefaults'

        expect(view._markupDefaults).not.toHaveBeenCalled()
        view.renderData()
        expect(view._markupDefaults).toHaveBeenCalled()


    describe 'EditSummaryView::_transferNonDefaultValues', ->

      it 'should be a function', ->
        expect(typeof EditSummaryView::_transferNonDefaultValues)
            .toBe 'function'

      it 'should be called by setModel', ->
        view = new EditSummaryView viewOptions()
        spyOn view, '_transferNonDefaultValues'

        expect(view._transferNonDefaultValues).not.toHaveBeenCalled()
        view.setModel model()
        expect(view._transferNonDefaultValues).toHaveBeenCalled()

      it 'should transfer to the new model attributes on the old model that were
          different from their default values', ->
        model0 = model
          title: 'title0'
          description: 'description0'
          thumbnail: 'thumbnail0.jpg'

        spyOn(model0, 'defaultAttributes').andReturn
          title: 'La La La'
          description: 'La la la'
          thumbnail: 'lalala.jpg'

        model1 = model
          title: 'title1'
          description: 'description1'
          thumbnail: 'thumbnail1.jpg'

        view = new EditSummaryView viewOptions model: model0

        expect(model1.title()).toBe 'title1'
        expect(model1.description()).toBe 'description1'
        expect(model1.thumbnail()).toBe 'thumbnail1.jpg'

        view.setModel model1

        expect(model1.title()).toBe 'title0'
        expect(model1.description()).toBe 'description0'
        expect(model1.thumbnail()).toBe 'thumbnail0.jpg'

      it 'should not transfer to the new model attributes on the old model that
          were set to their default values', ->
        model0 = model
          title: 'title0'
          description: 'description0'
          thumbnail: 'thumbnail0.jpg'

        spyOn(model0, 'defaultAttributes').andReturn
          title: 'title0'
          description: 'description0'
          thumbnail: 'thumbnail0.jpg'

        model1 = model
          title: 'title1'
          description: 'description1'
          thumbnail: 'thumbnail1.jpg'

        view = new EditSummaryView viewOptions model: model0

        expect(model1.title()).toBe 'title1'
        expect(model1.description()).toBe 'description1'
        expect(model1.thumbnail()).toBe 'thumbnail1.jpg'

        view.setModel model1

        expect(model1.title()).toBe 'title1'
        expect(model1.description()).toBe 'description1'
        expect(model1.thumbnail()).toBe 'thumbnail1.jpg'


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new EditSummaryView viewOptions()
    view.render()
    $player.append view.el
