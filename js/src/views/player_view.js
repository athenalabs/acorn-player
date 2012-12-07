(function() {

var player = acorn.player;

// ** player.PlayerView ** the acorn player main view
// --------------------------------------------------------
player.PlayerView = Backbone.View.extend({

  className: 'acorn-player',

  events: {
    'click #logo.thumbnail-icon': 'triggerAcornSite',
    'click #type.thumbnail-icon': 'triggerShowContent',
    'click #image':               'triggerShowContent',
  },

  // Supported trigger events
  //
  // * rename:acorn - fired when acorn has been renamed
  // * change:acorn - fired when acorn data has changed
  // * save:acorn   - fired when acorn needs to be saved
  //
  // * show:content - fired when ContentView should be shown
  // * show:edit    - fired when EditView should be shown
  // * close:edit   - fired when EditView should be closed
  // * show:sources - fired when SourcesView should be shown
  // * close:sources - fired when SourcesView should be closed
  //
  // * fullscreen   - fired when acorn should display in fullscreen
  // * acorn-site   - fired to go to the acorn website
  //
  // * playback:play - fired when playback should start or resume
  // * playback:stop - fired when playback should pause or stop
  // * playback:ended - fired when playback has finished



  defaults: {
    showingContent: false,
    // showingContent: whether the contentView ought to be visible.
    // once true, the player should respect the state when re-rendering
    // (i.e. re-rendering should still show the content, not revert to thumb).

    autohideControls: false,
    // autohideControls: whether the acorn controls should auto-hide.
    // this option only sets css class ``.autohide-controls``.
    // css controls the actual meaning of ``auto-hiding``.
  },

  initialize: function() {
    _.bindAll(this);

    // Track the acornid for rename checks
    this._acornid = this.model.acornid();

    // initialize with the shell the model has.
    this.shell = acorn.shellWithAcorn(this.model);

    // set option defauls.
    this.options = _.extend({}, this.defaults, this.options);

    this.on('rename:acorn', this.onAcornRename);
    this.on('change:acorn', this.onAcornChange);
    this.on('save:acorn', this.onAcornSave);

    this.on('show:content', this.onShowContent);

    this.on('show:edit', this.onShowEdit);
    this.on('close:edit', this.onCloseEdit);

    this.on('show:sources', this.onShowSources);
    this.on('close:sources', this.onCloseSources);

    this.on('fullscreen', this.onFullscreen);
    this.on('acorn-site', this.onAcornSite);

    // Subviews
    this.thumbnailView = new player.ThumbnailView({ player: this });
    this.controlsView = new player.ControlsView({ player: this });
    this.contentView = new player.ContentView({ player: this });

    // Order of binding events currently matters. The particular case was:
    // * ``new player.ControlsView({ player: this });`` binds first
    // * ``this.on('change:acorn', this.onAcornChange);`` binds second
    // * ``onAcornChange`` sets ``this.shell = ...``, ControlsView needs it.
    //
    // Subject to change.
    // see commit message https://github.com/athenalabs/acorn/commit/b1c1587
  },

  render: function() {
    this.$el.empty();

    if (this.options.autohideControls)
      this.$el.addClass('autohide-controls');

    this.thumbnailView.render();
    this.$el.append(this.thumbnailView.el);

    if (this.options.showingContent) {
      this.contentView.render();
      this.controlsView.render();

      // give shellView a handle to shellControls
      this.setShellControls();

      this.$el.append(this.contentView.el);
      this.$el.append(this.controlsView.el);
    }
  },

  setShellControls: function() {
    var shellView, shellControls;

    shellView = this.contentView.shellView;
    shellControls = this.controlsView.shellControls;

    acorn.util.assert(shellControls && shellView,
                      'ContentView and ControlsView must be rendered');

    shellView.setControlsView(shellControls);
  },

  onAcornSave: function() {
    // if there haven't been any changes, just close.
    if (!this.editView.isDirty()) {
      this.trigger('close:edit');
      return;
    }

    var self = this;
    var data = this.editView.editingShell.data;
    this.model.shellData(data);

    this.model.save({
      success: function() {
        self.trigger('close:edit');
        self.trigger('change:acorn');
        if (self._acornid != self.model.acornid())
          self.trigger('rename:acorn', self.model.acornid());
      },
      error: function() {
        acorn.alert('Error: failed to save model.', 'alert-error');
      },
    });
  },

  onAcornRename: function(acornid) {
    this._acornid = acornid;
  },

  onAcornChange: function() {
    this.shell = acorn.shellWithAcorn(this.model);
    this.render();
  },

  onShowContent: function() {
    this.options.showingContent = true;
    this.render();

    this.thumbnailView.$el.hide(1000);
  },

  triggerShowContent: function() {
    this.trigger('show:content');
  },

  onShowEdit: function() {
    if (this.editView)
      return;

    this.editView = new player.EditView({ player: this });
    this.editView.$el.css('opacity', 0.0);
    this.$el.append(this.editView.el);
    this.editView.render();
    this.editView.$el.css('opacity', 1.0);

    this.trigger('playback:stop');
  },

  onCloseEdit: function() {
    if (!this.editView)
      return;

    this.editView.$el.hide();
    this.editView.remove();
    this.editView = undefined;
  },

  triggerEdit: function() {
    this.trigger('show:edit');
  },

  onShowSources: function() {
    if (this.sourcesView)
      return;

    this.sourcesView = new player.SourcesView({ player: this });
    this.sourcesView.render();
    this.$el.append(this.sourcesView.el);

    this.trigger('playback:stop');
  },

  onCloseSources: function() {
    if (!this.sourcesView)
      return;

    this.sourcesView.$el.hide();
    this.sourcesView.remove();
    this.sourcesView = undefined;
  },

  onFullscreen: function() {
    var elem = this.$el[0];
    if (elem.requestFullscreen) {
      elem.requestFullscreen();
    } else if (elem.webkitRequestFullScreen) {
      elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
    } else if (elem.mozRequestFullScreen) {
      elem.mozRequestFullScreen();
    }
  },

  onAcornSite: function() {
    var url = acorn.util.url(this.model.acornid());
    window.open(url, '_blank');
  },

  triggerAcornSite: function() {
    this.trigger('acorn-site');
  },

  error: function(errstr) {
    this.$el.text(errstr);
  },

});

}).call(this);
