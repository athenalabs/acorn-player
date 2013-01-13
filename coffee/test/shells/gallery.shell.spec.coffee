goog.provide 'acorn.specs.shells.GalleryShell'

goog.require 'acorn.shells.GalleryShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.GalleryShell', ->
  test = athena.lib.util.test
  GalleryShell = acorn.shells.GalleryShell

  Model = GalleryShell.Model
  MediaView = GalleryShell.MediaView
  RemixView = GalleryShell.RemixView

  options =
    shellid: 'acorn.GalleryShell'
    shells: [
      {shellid: 'acorn.TextShell', text: 'Foo'},
      {shellid: 'acorn.TextShell', text: 'Bar'},
      {shellid: 'acorn.TextShell', text: 'Biz'},
      {shellid: 'acorn.TextShell', text: 'Baz'},
    ]

  model = new GalleryShell.Model options

  it 'should be part of acorn.shells', ->
    expect(GalleryShell).toBeDefined()

  acorn.util.test.describeShellModule GalleryShell, ->

    describe 'GalleryShell.MediaView', ->

      test.describeSubview
        View: GalleryShell.MediaView
        Subview: athena.lib.GridView
        subviewAttr: 'gridView'
        viewOptions: {model: model}

      it 'should call showView on `gridView.GridTile:Click`', ->
        view = new GalleryShell.MediaView model: model
        view.render()
        spyOn view, 'showView'
        tile = view.gridView.tileViews[0]
        tile.trigger 'GridTile:Click', tile
        expect(view.showView).toHaveBeenCalled()

      it 'should call hideView on `controlsView.GridControl:Click`', ->
        view = new GalleryShell.MediaView model: model
        view.render()
        spyOn view, 'hideView'
        view.controlsView.trigger 'GridControl:Click'
        expect(view.hideView).toHaveBeenCalled()

      it 'should hide controlsView on hideView', ->
        view = new GalleryShell.MediaView model: model
        view.render()
        spy = spyOn view.controlsView.$el, 'hide'
        view.hideView()
        expect(spy).toHaveBeenCalled()

      it 'should show gridView on hideView', ->
        view = new GalleryShell.MediaView model: model
        view.render()
        spy = spyOn view.gridView.$el, 'show'
        view.hideView()
        expect(spy).toHaveBeenCalled()

      it 'should show controlsView on showView', ->
        view = new GalleryShell.MediaView model: model
        view.render()
        spy = spyOn view.controlsView.$el, 'show'
        view.showView()
        expect(spy).toHaveBeenCalled()

      it 'should hide gridView on showView', ->
        view = new GalleryShell.MediaView model: model
        view.render()
        spy = spyOn view.gridView.$el, 'hide'
        view.showView()
        expect(spy).toHaveBeenCalled()


  it 'its views should look good', ->
    # setup DOM
    acorn.util.appendCss()
    $player = $('<div>').addClass('acorn-player').appendTo('body')

    contentView = new GalleryShell.MediaView model: model
    contentView.$el.width 600
    contentView.render()
    $player.append contentView.el


    remixView = new GalleryShell.RemixView model: model
    remixView.$el.width 600
    remixView.render()
    $player.append remixView.el
