goog.provide 'acorn.specs.shells.RandomShell'

goog.require 'acorn.shells.RandomShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.RandomShell', ->
  test = athena.lib.util.test
  RandomShell = acorn.shells.RandomShell

  Model = RandomShell.Model
  MediaView = RandomShell.MediaView
  RemixView = RandomShell.RemixView

  options =
    shellid: 'acorn.RandomShell'
    shells: [
      {shellid: 'acorn.TextShell', text: 'Foo'},
      {shellid: 'acorn.TextShell', text: 'Bar'},
      {shellid: 'acorn.TextShell', text: 'Biz'},
      {shellid: 'acorn.TextShell', text: 'Baz'},
    ]

  model = new RandomShell.Model options

  it 'should be part of acorn.shells', ->
    expect(RandomShell).toBeDefined()

  acorn.util.test.describeShellModule RandomShell, ->

    describe 'RandomShell.MediaView', ->

      it 'should call showRandom on `controlsView.RandomControl:Click`', ->
        view = new RandomShell.MediaView model: model
        view.render()
        spyOn view, 'showRandom'
        expect(view.showRandom).not.toHaveBeenCalled()
        view.controlsView.trigger 'RandomControl:Click'
        expect(view.showRandom).toHaveBeenCalled()

      describe 'MediaView::showRandom', ->

        it 'should call `switchShell` with offset 0', ->
          view = new RandomShell.MediaView model: model
          view.render()
          spyOn view, 'switchShell'
          expect(view.switchShell).not.toHaveBeenCalled()
          view.controlsView.trigger 'RandomControl:Click'
          expect(view.switchShell).toHaveBeenCalled()
          expect(view.switchShell.mostRecentCall.args[1]).toBe 0

        it 'should call `switchShell` with a random index i such that 0 <= i <
            shellViews.length', ->
          view = new RandomShell.MediaView model: model
          view.render()

          length = view.shellViews.length
          fakeRandom = 0
          spyOn view, 'switchShell'
          spyOn(Math, 'random').andCallFake -> fakeRandom

          for i in [0..9]
            fakeRandom = i / 10
            expect(view.switchShell.callCount).toBe i
            view.showRandom()
            expect(view.switchShell.callCount).toBe i + 1
            index = view.switchShell.mostRecentCall.args[0]
            expect(index).toBe Math.floor fakeRandom * length


  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    contentView = new RandomShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new RandomShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
