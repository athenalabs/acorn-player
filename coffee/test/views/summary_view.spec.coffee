goog.provide 'acorn.specs.player.SummaryView'
goog.require 'acorn.player.SummaryView'
goog.require 'acorn.shells.TextShell'

describe 'acorn.player.ShellEditorView', ->
  test = athena.lib.util.test

  SummaryView = acorn.player.SummaryView
  TextShell = acorn.shells.TextShell

  # model for EditorView contruction
  model = new TextShell.Model
    title: 'Title of the Best Acorn Ever'
    description: 'Description of the Best Acorn Ever: this acorn is the
      absolute best acorn ever, \'tis true. Description of the Best Acorn Ever:
      this acorn is the absolute best acorn ever, \'tis true.'

  options = model: model


  it 'should be part of acorn.player', ->
    expect(SummaryView).toBeDefined()


  test.describeDefaults SummaryView, {
    editable: false
  }, options


  test.describeView SummaryView, athena.lib.View, options


  it 'should call renderData on event changes', ->
    view = new SummaryView model: model.clone()
    spyOn view, 'renderData'

    view.model.title('Foo')
    expect(view.renderData).not.toHaveBeenCalled() # not rendering

    view.render()
    view.model.title('Foo')
    expect(view.renderData).toHaveBeenCalled() # rendering


  it 'should call renderData on event changes (after setModel)', ->
    view = new SummaryView model: model
    spyOn view, 'renderData'

    view.setModel model.clone()
    view.model.title('Foo')
    expect(view.renderData).not.toHaveBeenCalled() # not rendering

    view.render()
    view.model.title('Foo')
    expect(view.renderData).toHaveBeenCalled() # rendering


  it 'should render normal template if editable is false', ->
    view = new SummaryView {model: model.clone(), editable: false}
    spyOn view, 'template'
    spyOn view, 'editableTemplate'
    view.render()
    expect(view.template).toHaveBeenCalled()
    expect(view.editableTemplate).not.toHaveBeenCalled()


  it 'should render editable template if editable is true', ->
    view = new SummaryView {model: model.clone(), editable: true}
    spyOn view, 'template'
    spyOn view, 'editableTemplate'
    view.render()
    expect(view.template).not.toHaveBeenCalled()
    expect(view.editableTemplate).toHaveBeenCalled()


  it 'should not have editable class if editable is false', ->
    view = new SummaryView {model: model.clone(), editable: false}
    view.render()
    expect(view.$el.hasClass 'editable').toBe false


  it 'should have editable class if editable is true', ->
    view = new SummaryView {model: model.clone(), editable: true}
    view.render()
    expect(view.$el.hasClass 'editable').toBe true


  it 'should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    # add to the DOM to see how it looks.
    view = new SummaryView {model: model, editable: false}
    view.render()
    $player.append view.el

    $player.append $('<br />')

    # add to the DOM to see how it looks.
    view = new SummaryView {model: model, editable: true}
    view.render()
    $player.append view.el
