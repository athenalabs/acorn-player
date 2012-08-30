// acorn.shells.MultiShell -- one shell to contain them all.
// ---------------------------------------------------------

var MultiShell = acorn.shells.MultiShell = Shell.extend({
  // leelo dallas multi shell

  shellid: 'acorn.MultiShell',

  // The cannonical type of this media. One of `acorn.types`.
  type: 'multimedia',

  // The shell-specific control components to use.
  controls: [
    'LeftControl',
    'ListControl',
    'RightControl',
  ],

  initialize: function() {
    Shell.prototype.initialize.call(this);

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

MultiShell.ContentView = Shell.ContentView.extend({

  // **shellViews** is a container for sub shellViews.
  shellViews: [],

  // Supported trigger events
  //
  // * change:subview - fired when subview currently show changes.

  initialize: function() {
    Shell.ContentView.prototype.initialize.call(this);

    // controls
    this.parent.on('controls:left', this.onShowPrevious);
    this.parent.on('controls:list', this.onShowPlaylist);
    this.parent.on('controls:right', this.onShowNext);

    // multishell events
    this.on('change:subview', this.onChangedSubview);

    // initialize shells
    this.shells = _.map(this.shell.data.shells, acorn.shellWithData);
    _.map(this.shells, function (shell) { shell.retrieveExtraInfo(); });

  },

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

  showView: function(index) {
    var shellView = this.shellViews[index];

    // bail if no view at that index.
    if (!shellView)
      return;

    // tear down previous ``currentView``
    if (this.currentView) {
      this.currentView.remove();
      // removing may be a bit drastic. perhaps:
      // this.currentView.stop();
      // this.currentView.$el.hide();
    }

    // set up shellView as ``currentView``
    this.currentView = shellView;
    if (!this.currentView.el.parentNode) {
      this.currentView.render();
      this.$el.append(this.currentView.el);
    }

    this.currentView.$el.show();

    // announce changes
    this.trigger('change:subview');
  },

  // **showPlaylist** bring up a container with subview summaries
  showPlaylist: function() {
    // only open playlist once.
    var playlistId = this.shell.shellClass.PlaylistView.prototype.id;
    if (this.$el.find('#' + playlistId).length > 0)
      return;

    var playlistView = new this.shell.shellClass.PlaylistView({
      shell: this.shell,
      parent: this,
    });

    playlistView.render();
    this.$el.append(playlistView.el);

    // stop playback on the currently-playing view
    this.currentView.stop();
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

  // **onShowPrevious** move back in the playlist.
  onShowPrevious: function() {
    this.showView(this.currentViewIndex() - 1);
  },

  // **onShowNext** move forward in the playlist.
  onShowNext: function() {
    this.showView(this.currentViewIndex() + 1);
  },

  // **onShowPlaylist** show the playlist to the user.
  onShowPlaylist: function() {
    this.showPlaylist();
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

MultiShell.PlaylistView = ShellView.extend({

  id: 'acorn-multishell-playlist',

  template: _.template('\
    <h1 id="title"></h1>\
    <button id="close" class="btn">\
      <i class="icon-ban-circle"></i> Close\
    </button>\
    <div id="summaries"></div>\
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

    var currentIndex = this.parent.currentViewIndex();

    var summaries = this.$el.find('#summaries');
    _.map(this.parent.shells, function(shell, idx) {

      var summary = new shell.shellClass.SummaryView({
        shell: shell,
        parent: this,
        autplay: this.options.autoplay,
      });

      summary.render();
      summaries.append(summary.el);

      // if this is the currently-viewed shell, mark it selected
      if (idx == currentIndex)
        summary.$el.addClass('selected');

      // an action to view shells from the playlist
      var view_btn =
        $('<button>')
          .text('View')
          .addClass('btn')
          .attr('id', 'view')
          .attr('data-index', idx);

      summary.$el.find('#buttons').append(view_btn);

    }, this);

  },

  onClickClose: function() {
    this.remove();
  },

  onClickView: function(event) {
    var index = $(event.target).attr('data-index');
    this.parent.showView(index);
    this.remove();
  },

});


// EditView -- displays the subshell EditViews.
// --------------------------------------------

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
    var indexOf = this.shell.shellClass.ContentView.prototype.indexOfView;
    return indexOf.call(this, view);
  },

  // helper to map `func` through `shellViews` with `this` as context
  map: function(func) {
    return _.map(this.shellViews, func, this);
  },

});


// Register the shell with the acorn object.
acorn.registerShell(MultiShell);
