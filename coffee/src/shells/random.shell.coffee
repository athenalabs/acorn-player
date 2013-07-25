`import "collection.shell.js"`


CollectionShell = acorn.shells.CollectionShell


RandomShell = acorn.shells.RandomShell =

  id: 'acorn.RandomShell'
  title: 'Random Selector'
  description: 'selects a random media item from a list'
  icon: 'icon-magic'



class RandomShell.Model extends CollectionShell.Model



class RandomShell.MediaView extends CollectionShell.MediaView


  className: @classNameExtend 'random-shell'


  defaults: => _.extend super,
    playOnReady: true
    readyOnRender: true
    showFirstSubshellOnRender: false
    showSubshellControls: true
    showSubshellSummary: true
    autoAdvanceOnEnd: false
    playSubshellOnProgression: true


  initializeControlsView: =>
    # construct a ControlToolbar for the acorn controls
    @controlsView = new ControlToolbarView
      extraClasses: ['shell-controls']
      buttons: ['Random']
      eventhub: @eventhub

    @listenTo @controlsView, 'RandomControl:Click', => @showRandom()


  render: =>
    super
    @showRandom()
    @


  showRandom: =>
    randomIndex = Math.floor Math.random() * @shellViews.length

    # select random shell and restart it
    @switchShell randomIndex, 0



class RandomShell.RemixView extends CollectionShell.RemixView


  className: @classNameExtend 'random-shell'



acorn.registerShellModule RandomShell
