goog.provide 'acorn.specs.shells.EmptyShell'

goog.require 'acorn.shells.EmptyShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.EmptyShell', ->
  test = athena.lib.util.test
  Shell = acorn.shells.Shell
  EmptyShell = acorn.shells.EmptyShell
  TextShell = acorn.shells.TextShell

  it 'should be part of acorn.shells', ->
    expect(EmptyShell).toBeDefined()

  acorn.util.test.describeShellModule EmptyShell, ->

    options =
      model: new EmptyShell.Model
        shellid: 'acorn.EmptyShell'


    describe 'EmptyShell.RemixView', ->

      test.describeSubview
        View: EmptyShell.RemixView
        Subview: acorn.player.ShellSelectorView
        subviewAttr: 'selectorView'
        viewOptions: options

      it 'should have an active link input', ->
        expect(EmptyShell.RemixView.activeLinkInput).toBe true

      it 'should trigger Remix:SwapShell on ShellSelector:Selected', ->
        view = new EmptyShell.RemixView options
        spy = new test.EventSpy view, 'Remix:SwapShell'
        view.render()
        view.selectorView.trigger(
          'ShellSelector:Selected', view.selectorView, 'acorn.TextShell')
        expect(spy.triggered).toBe true

      it 'should trigger Remix:SwapShell with oldModel, newModel', ->
        view = new EmptyShell.RemixView options
        spy = new test.EventSpy view, 'Remix:SwapShell'
        view.render()
        view.selectorView.trigger(
          'ShellSelector:Selected', view.selectorView, 'acorn.TextShell')
        expect(spy.arguments[0][0]).toBe view.model
        expect(spy.arguments[0][1] instanceof TextShell.Model).toBe true

      it 'should throw if module is invalid', ->
        view = new EmptyShell.RemixView options
        spy = new test.EventSpy view, 'Remix:SwapShell'
        view.render()
        expect( -> view.selectorView.trigger(
          'ShellSelector:Selected', view.selectorView, 'foo')).toThrow()



  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    model = new EmptyShell.Model
      shellid: 'acorn.EmptyShell'

    contentView = new EmptyShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new EmptyShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
