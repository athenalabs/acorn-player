// acorn.shells.MultiShell -- one shell to contain them all.
// ---------------------------------------------------------

// The idea behind MultiShell is that it provides a generic group for
// other shells. It provides the basic, core functionality necessary
// to construct one unified shell out of other "subshells".
//
// Types of media groups made possible by MultiShell are, for example:
// * Playlists
// * Galleries
// * Slideshows
// * Spliced Video
//
// MultiShell does its magic by a simple abstraction, it interacts with
// acorn as one single shell, and then directs actions/events to the
// specific subshells that should get them.
//
// MultiShell is represented by a list (array) of subshells.
// For example, take http://staging.acorn.athena.ai/yuiezzhxqa:
//
// {
//   "shell": "acorn.MultiShell",
//   "shells": [
//     {
//       "link": "http://www.youtube.com/watch?v=OQSNhk5ICTI",
//       "shell": "acorn.YouTubeShell",
//     },
//     {
//       "link": "http://www.youtube.com/watch?v=MX0D4oZwCsA",
//       "shell": "acorn.YouTubeShell"
//     }
//   ]
// }
//
// Note that the order of the shells in the array is significant, as
// MultiShell uses this order to present the subshells.


var MultiShell = acorn.shells.MultiShell = Shell.extend({
  // leelo dallas multi shell

  // shellid specifies the shell type, which will be stored in the
  // ``shell.shell`` value.
  shellid: 'acorn.MultiShell',

  // The canonical type of this media. One of `acorn.types`.
  type: 'multimedia',

  // The shell-specific control components to use.
  // These controls are specified from Left to Right on the ControlsView.
  controls: [

    // Left provides a way to go back to the previous subshell.
    'Left',

    // List provides a way to toggle the playlist showing all subshells.
    'List',

    // Right provides a way to go forwards to the next subshell.
    'Right',
  ],

  initialize: function() {
    Shell.prototype.initialize.call(this);

    // ensure we have an internal data structure for our subshells.
    this.data.shells = this.data.shells || [];
  },

  // **title** returns a simple title of the shell
  title: function() {
    var items = _.keys(this.data.shells).length;
    var s = (items == 1 ? '' : 's');
    return 'playlist with ' + items + ' item' + s;
  },

  // **thumbnailLink** use the first shell's thumbnail
  thumbnailLink: function() {
    var first = this.data.shells[0];
    if (!first)
      return '';

    var shell = acorn.shellWithData(first);
    return shell.thumbnailLink();
  },

  // **addShellData** adds another shell (via data)
  addShellData: function(shellData) {
    this.data.shells.push(shellData);
  },

  // **addShell** adds another shell
  addShell: function(shell) {
    this.addShellData(shell.data)
  },

});



// **ContentView** - Render each subshell in sequence.
// ---------------------------------------------------

// The MultiShell.ContentView shows each shell individually,
// keeping track of the current shell (through currentView).
// Rendering of the media is left entirely to the specific subshell.
//
// It listens to the 'left', 'list', and 'right' events from
// the Player.ContentView to navigate.

MultiShell.ContentView = Shell.ContentView.extend({

  // **shellViews** is a container for sub shellViews.
  shellViews: [],

  // overwrite 'acorn-shell' as classname
  className: 'acorn-multishell',

  // Supported trigger events
  //
  // * change:subview - fired when subview currently shown changes.

  initialize: function() {
    Shell.ContentView.prototype.initialize.call(this);

    // controls
    this.parent.on('controls:left', this.onShowPrevious);
    this.parent.on('controls:list', this.onTogglePlaylist);
    this.parent.on('controls:right', this.onShowNext);

    // multishell events
    this.on('change:subview', this.onChangedSubview);

    // initialize shells
    this.shells = _.map(this.shell.data.shells, acorn.shellWithData);
    _.map(this.shells, function (shell) { shell.retrieveExtraInfo(); });

  },

  // **render** construct and keep all the shellViews in memory, but
  // only show one at a time.
  render: function() {
    // remove all previously rendered shellViews.
    this.map(function(shellView) { shellView.remove(); });

    // construct all the views
    this.shellViews = _.map(this.shells, function (shell) {
      var contentView = new shell.shellClass.ContentView({
        shell: shell,
        parent: this,
        autoplay: true,
      });

      // subshell events
      contentView.on('playback:ended', this.onSubShellPlaybackEnded);

      return contentView;
    }, this);

    // clean up our elem
    this.$el.empty();

    this.showView(0)
  },

  indexOfView: function(view) {
    return _.indexOf(this.shellViews, view);
  },

  currentViewIndex: function() {
    return this.indexOfView(this.currentView);
  },

  // **showView** - shows the view at the specified index.
  showView: function(index) {
    var shellView = this.shellViews[index];

    // bail if no view at that index.
    if (!shellView)
      return;

    // tear down previous ``currentView``
    if (this.currentView) {
      this.currentView.remove();
      // removing may be a bit drastic. perhaps:
      // this.triggerPlaybackStop();
      // this.currentView.$el.hide();
    };

    // set up shellView as ``currentView``
    this.currentView = shellView;

    if (!this.currentView.el.parentNode) {
      this.currentView.render();
      this.$el.append(this.currentView.el);
    };

    this.currentView.$el.show();

    // announce changes
    this.trigger('change:subview');
  },

  // **togglePlaylist** toggle a container with subview summaries
  togglePlaylist: function() {
    if (this.playlistView) {
      this.playlistView.close();
      this.playlistView = undefined;
      return;
    };

    var playlistView = new this.shell.shellClass.PlaylistView({
      shell: this.shell,
      parent: this,
    });

    this.playlistView = playlistView;

    playlistView.render();
    this.$el.append(playlistView.el);

    // stop playback on the currently-playing view
    this.triggerPlaybackStop();
  },

  // -- MultiShell Events

  onChangedSubview: function() {
    var contentView = this.parent;
    var controlsView = contentView.player.controlsView;

    var left = controlsView.controlWithId('left');
    var list = controlsView.controlWithId('list');
    var right = controlsView.controlWithId('right');

    left.$el.removeAttr('disabled');
    right.$el.removeAttr('disabled');

    if (this.currentView == _.first(this.shellViews))
      left.$el.attr('disabled', 'disabled');

    if (this.currentView == _.last(this.shellViews))
      right.$el.attr('disabled', 'disabled');
  },

  triggerPlaybackStop: function() {
    this.trigger('playback:stop');
  },

  // **onPlaybackStop** forward 'stop:playback' event from parent
  onPlaybackStop: function() {
    this.triggerPlaybackStop();
  },

  // **onShowPrevious** move back in the playlist.
  onShowPrevious: function() {
    this.showView(this.currentViewIndex() - 1);
  },

  // **onShowNext** move forward in the playlist.
  onShowNext: function() {
    this.showView(this.currentViewIndex() + 1);
  },

  // **onTogglePlaylist** toggle showing the playlist to the user.
  onTogglePlaylist: function() {
    this.togglePlaylist();
  },

  // -- SubShell Events

  // **onSubShellPlaybackEnded** advance subshells
  onSubShellPlaybackEnded: function() {
    // if there are more subshells to play, play them.
    if (this.hasNext())
      this.onShowNext();

    // otherwise, signal multishell playback ended.
    else
      this.trigger('playback:ended');
  },


  // helper to know whether there are more subshells forward.
  hasNext: function() {
    return this.currentViewIndex() < this.shellViews.length - 1;
  },

  // helper to know whether there are more subshells backward.
  hasPrevious: function() {
    return this.currentViewIndex() > 0;
  },

  // helper to map `func` through `shellViews` with `this` as context
  map: function(func) {
    _.map(this.shellViews, func, this);
  },

});



// **PlaylistView** - A view to summarize the shells within a MultiShell
// ---------------------------------------------------------------------

// The MultiShell.PlaylistView shows a list of subshell summaries.
// It highlights the currently shown shell, and provides a button to jump
// to each subshell.


MultiShell.PlaylistView = ShellView.extend({

  id: 'acorn-multishell-playlist',

  template: _.template('\
    <div class="clear-cover"></div>\
    <div class="background"></div>\
    <div class="content">\
      <h1 id="title"></h1>\
      <button id="close" class="btn">\
        <i class="icon-ban-circle"></i> Close\
      </button>\
      <div id="summaries"></div>\
    </div>\
  '),

  events: {
    'click button#close': 'onClickClose',
    'click button#view': 'onClickView',
  },

  render: function() {
    this.$el.empty();
    this.$el.html(this.template());

    var title = this.shell.title();
    this.$el.find('#title').text(title);

    var summaries = this.$el.find('#summaries');
    _.map(this.parent.shells, function(shell, idx) {

      var summary = new shell.shellClass.SummaryView({
        shell: shell,
        parent: this,
        autplay: this.options.autoplay,
      });

      summary.render();
      summaries.append(summary.el);
      summary.$el.attr('data-index', idx);

      // an action to view shells from the playlist
      var view_btn =
        $('<button>')
          .text('View')
          .addClass('btn')
          .attr('id', 'view')
          .attr('data-index', idx);

      summary.$el.find('#buttons').append(view_btn);

    }, this);

    // select current shell and respond when current shell changes
    this.parent.on('change:subview', this.onChangedSubview);
    this.updateSelected();

  },

  onChangedSubview: function () {
    this.updateSelected();
  },

  updateSelected: function() {
    var summaries = this.$el.find('#summaries');
    var currentIndex = this.parent.currentViewIndex();
    var selector = "[data-index='"+currentIndex+"']:not('button')";

    // unselect any selected summaries and select the current shell's summary
    summaries.find('.selected').removeClass('selected');
    summaries.find(selector).addClass('selected');
  },

  close: function() {
    this.remove();
  },

  onClickClose: function() {
    this.close();
  },

  onClickView: function(event) {
    var index = $(event.target).attr('data-index');
    this.parent.showView(index);
    this.remove();
  },

});


// EditView -- displays the subshell EditViews.
// --------------------------------------------

// The MultiShell.EditView shows each subshell.EditView in a list.
// It allows editing of all subshells in the same list.


MultiShell.EditView = Shell.EditView.extend({

  // **shellViews** is a container for sub shellViews.
  shellViews: [],

  events: {
    'click button#add': 'onClickAdd',
  },

  template: _.template('\
    <div id="subshells"></div>\
    <button class="btn btn-large" id="add">Add Link</button>\
  '),

  render: function() {

    // remove all previously rendered shellViews.
    this.map(function(shellView) { shellView.remove(); });

    // construct all the views
    this.shellViews = _.map(this.shell.data.shells, function(data, index) {
      return this.constructView(data, index);
    }, this);

    // clean up our elem
    this.$el.empty();
    this.$el.append(this.template());

    var subshells_el = this.$el.find('#subshells');

    // render and append all shellViews.
    this.map(function (shellView) {
      shellView.render();
      subshells_el.append(shellView.el);
    });

  },

  constructView: function(shellData, index) {
    // retrieve shell class from data info
    var shell = acorn.shellWithData(shellData);

    // construct this shell's EditView.
    var shellView = new shell.shellClass.EditView({
      shell: shell,
      parent: this,
    });

    // listen to events of shell EditView
    shellView.on('swap:shell', function(data) {
      this.onSwapSubShell(data, shellView);
    }, this);

    shellView.on('change:shell', function(data) {
      this.onChangeSubShell(data, shellView);
    }, this);

    shellView.on('delete:shell', function() {
      this.onDeleteSubShell(shellView);
    }, this);

    shellView.on('change:editState', this.onChangeEditState);

    return shellView;
  },

  // -- Shell Overrides

  // **isEditing** returns whether any shellView isEditing
  isEditing: function(value) {
    return _.any(this.shellViews, function (shellView) {
      return shellView.isEditing();
    });
  },

  // **onChangeShell** overriden to prevent re-render
  onChangeShell: function() {},

  // **finalizeEdit** propagate to subshells
  finalizeEdit: function() {
    this.map(function (shellView) {
      return shellView.finalizeEdit();
    });

    // remove empty shells (but ensure at least one shell remains)
    var emptyShellData = this.emptyShellData();
    var shells = this.shells();
    shells = _.filter(shells, function(shell) {
      return !_.isEqual(shell, emptyShellData);
    });
    shells = shells.length === 0 ? [emptyShellData] : shells;
    this.shells(shells);
  },

  // -- MultiShell Events

  onChangeEditState: function() {
    this.trigger('change:editState');
  },

  // **onClickAdd** add another link + shell
  onClickAdd: function() {
    // // additional, placeholder adding shells
    var nextIndex = this.shellViews.length;
    var addData = this.emptyShellData();
    var addView = this.constructView(addData, nextIndex);

    addView.render();
    this.shellViews.push(addView);

    var subshells_el = this.$el.find('#subshells');
    subshells_el.append(addView.el);
  },

  // -- Sub Shell Events

  onSwapSubShell: function(data, shellView) {
    var index = this.indexOfView(shellView);
    var oldShellView = this.shellViews[index];
    var newShellView = this.constructView(data, index);

    // render and add the new shellView.
    newShellView.render();
    oldShellView.$el.after(newShellView.el);

    // remove old shellView
    oldShellView.remove();
    this.shellViews[index] = newShellView;

    // update the data itself
    var shells = this.shells();
    shells[index] = data;
    this.shells(shells);
  },

  onChangeSubShell: function(shell, shellView) {
    // update the data itself
    var index = this.indexOfView(shellView);
    var shells = this.shells();
    shells[index] = shell.data;
    this.shells(shells);
  },

  onDeleteSubShell: function(shellView) {
    // remove shell from `this.shellViews`
    var index = this.indexOfView(shellView);
    this.shellViews.splice(index, 1);

    // remove shell from `this.shells`
    var shells = this.shells();
    shells.splice(index, 1);
    this.shells(shells);

    // remove shellview
    shellView.remove();
  },

  // get/setter for shells value
  shells: function(shells) {
    if (shells !== undefined) {
      this.shell.data.shells = shells;

      // if there is at most 1 shell, swap.
      if (shells.length <= 1)
        this.trigger('swap:shell', shells[0] || {});

      // else, announce that the shell has changed.
      else
        this.trigger('change:shell', this.shell);
    }
    return this.shell.data.shells;
  },

  // create an empty link shell
  emptyShellData: function() {
    return acorn.shellForLink('').data;
  },

  // helper to return a view's index in `shellViews`
  indexOfView: function(view) {
    return _.indexOf(this.shellViews, view);
  },

  // helper to map `func` through `shellViews` with `this` as context
  map: function(func) {
    return _.map(this.shellViews, func, this);
  },

});


// Register the shell with the acorn object.
acorn.registerShell(MultiShell);
