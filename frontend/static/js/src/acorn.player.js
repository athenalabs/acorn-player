//     acorn.player.js 0.0.0
//     (c) 2012 Juan Batiz-Benet, Athena.
//     Acorn is freely distributable under the MIT license.
//     Inspired by github:gist.
//     Portions of code from Underscore.js and Backbone.js
//     For all details and documentation:
//     http://github.com/jbenet/acorn

(function() {

  // Setup
  // -----

  // Establish the root object, `window` in browser, or `global` on server.
  var root = this;

  // For acorn's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  var $ = root.jQuery || root.Zepto || root.ender;

  // Local handles for global variables.
  var _ = root._;
  var Backbone = root.Backbone;
  var acorn = root.acorn;

  // Ensure all our requirements are met:

  // Error out if acorn isn't present.
  if (acorn == undefined)
    throw new Error('acorn.player.js requires acorn.js');

  // Error out if acorn.shells isn't present.
  if (acorn.shells == undefined)
    throw new Error('acorn.player.js requires acorn.shells.js');

  // Error out if underscore isn't present.
  if (_ == undefined)
    throw new Error('acorn.player.js requires Underscore.js');

  // Error out if backbone isn't present.
  if (Backbone == undefined)
    throw new Error('acorn.player.js requires Backbone.js');


  // local handles
  var extend = acorn.util.extend;
  var assert = acorn.util.assert;


  // ** acorn.player ** the acorn.player library
  // -------------------------------------------

  // Flag that acorn.player.js is present.
  var player = acorn.player = {};

  // Current version.
  player.VERSION = '0.0.0';

  // Our Current web instance.
  player.instance = undefined;

  player.views = {};

  // ** player.views.PlayerView ** the acorn player main view
  // --------------------------------------------------------

  player.views.PlayerView = Backbone.View.extend({

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
    // * close:edit   - fired when EditView shold be closed
    //
    // * fullscreen   - fired when acorn should display in fullscreen
    // * acorn-site   - fired to go to the acorn website
    //
    // * playback:play - fired when playback should start or resume
    // * playback:stop - fired when playback should pause or stop



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

      // initialize with the shell the model has (can be undefined)
      this.shell = this.model.shellData();

      // set option defauls.
      this.options = _.extend({}, this.defaults, this.options);

      this.on('rename:acorn', this.onAcornRename);
      this.on('change:acorn', this.onAcornChange);
      this.on('save:acorn', this.onAcornSave);

      this.on('show:content', this.onShowContent);

      this.on('show:edit', this.onShowEdit);
      this.on('close:edit', this.onCloseEdit);

      this.on('fullscreen', this.onFullscreen);
      this.on('acorn-site', this.onAcornSite);

      // Subviews
      this.thumbnailView = new player.views.ThumbnailView({ player: this });
      this.controlsView = new player.views.ControlsView({ player: this });
      this.contentView = new player.views.ContentView({ player: this });

      // Order of binding events currently matters. The particular case was:
      // * ``new player.views.ControlsView({ player: this });`` binds first
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

        this.$el.append(this.contentView.el);
        this.$el.append(this.controlsView.el);
      }
    },

    onAcornSave: function() {
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

      this.editView = new player.views.EditView({ player: this });
      this.$el.append(this.editView.el);
      this.editView.render();
      this.editView.$el.css('opacity', 0.0);
      this.editView.$el.css('opacity', 1.0);

      //TODO: list this event somewhere on the top of this view...
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

    onFullscreen: function() {
      console.log('fullscreen triggered');
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


  // ** player.views.PlayerSubview ** a sub-component view for PlayerView
  // --------------------------------------------------------------------
  var PlayerSubview = player.views.PlayerSubview = Backbone.View.extend({

    initialize: function() {
      _.bindAll(this);
      _.defaults(this.options, this.defaults || {});

      this.player = this.options.player;
      assert(this.player, 'no player provided to PlayerSubview.');
    },

  });


  // ** player.views.ThumbnailView ** a view showing the acorn thumbnail
  // -------------------------------------------------------------------

  player.views.ThumbnailView = PlayerSubview.extend({

    template: _.template('\
      <img id="image" src="" />\
      <img id="type" src="" class="thumbnail-icon" />\
      <img id="logo" src="" class="thumbnail-icon" />\
    '),

    id: 'thumbnail',

    render: function() {

      this.$el.empty();

      var shelltype = this.player.shell.type;
      var typeurl = acorn.util.imgurl('icons', shelltype + '.png');
      var acornurl = acorn.util.imgurl('acorn.png');
      var thumburl = this.player.shell.thumbnailLink();

      this.$el.html(this.template());
      this.$el.find('#type').attr('src', typeurl);
      this.$el.find('#logo').attr('src', acornurl);
      this.$el.find('#image').attr('src', thumburl);

    },

  });


  // ** player.views.ContentView ** view that renders/embeds shells
  // --------------------------------------------------------------

  player.views.ContentView = PlayerSubview.extend({

    id: 'content',

    // Supported trigger events
    // * all PlayerView events (proxying)

    initialize: function() {
      PlayerSubview.prototype.initialize.call(this);

      // proxy player events over, so shell ContentViews can listen.
      this.player.on('all', this.trigger)
    },

    render: function() {

      if (this.shellView)
        this.shellView.remove();

      this.shellView = new this.player.shell.ContentView({
        shell: this.player.shell,
        parent: this,
        autoplay: true,
      });

      this.$el.empty();
      this.shellView.render();
      this.$el.append(this.shellView.el);

    },

  });


  // control views.
  player.views.controls = {};


  // ** player.views.ControlsView ** view with media control buttons
  // ---------------------------------------------------------------

  player.views.ControlsView = PlayerSubview.extend({

    id: 'controls',

    controls: [
      'FullscreenControl',
      'AcornControl',
      'EditControl',
    ],

    // Supported trigger events
    // * change:acorn - fired when acorn data has changed

    initialize: function() {
      PlayerSubview.prototype.initialize.call(this);

      this.player.on('change:acorn', this.onAcornChange);
    },

    render: function() {
      this.$el.empty();

      var self = this;
      _(this.controlViews).each(function(control) {
        // `control.el` got removed from the DOM above: `this.$el.empty()`.
        // the `control` view's elements thus need to be re-delegated.
        // (apparently this is how backbone works. this could potentially
        // be biting us elsewhere and we don't even know it!)
        control.delegateEvents();

        control.render();
        self.$el.append(control.el)
      });
    },

    onAcornChange: function() {

      var controls = this.controls;

      if (this.player.shell && this.player.shell.controls)
        controls = controls.concat(this.player.shell.controls);

      var self = this;
      this.controlViews = _(controls).chain()
        .map(function (ctrl) { return player.views.controls[ctrl]; })
        .filter(function (cls) { return !!cls; })
        .map(function (cls) { return new cls({controls: self}); })
        .value();

      this.render();
    },

    controlWithId: function(id) {
      return _.find(this.controlViews, function (ctrlView) {
        return ctrlView.id == id;
      });
    },

  });


  // ** player.views.Control ** superclass that all Controls inherit from
  // --------------------------------------------------------------------

  player.views.Control = Backbone.View.extend({
    tooltip: '',

    tagName: 'img',
    className: 'control',

    events: {
      'click': 'onClick',
    },

    initialize: function() {
      _.bindAll(this);

      this.controls = this.options.controls;
      if (!this.controls)
        throw new acorn.errors.ParameterError('controls');

    },

    render: function() {

      this.$el.empty();
      this.$el.attr('src', acorn.util.imgurl('controls', 'blank.png'));
      this.$el.tooltip({ title: this.tooltip });

    },

    onClick: function() {

    },

  });

  // ** player.views.controls.FullscreenControl ** onClick : fulscreen
  // -----------------------------------------------------------------

  player.views.controls.FullscreenControl = player.views.Control.extend({
    tooltip: 'Fullscreen',

    id: 'fullscreen',
    className: 'control right',

    onClick: function() {
      this.controls.player.trigger('fullscreen');
    },

  });

  // ** player.views.controls.FullscreenControl ** onClick : acorn website
  // ---------------------------------------------------------------------

  player.views.controls.AcornControl = player.views.Control.extend({
    tooltip: 'Website',

    id: 'acorn',
    className: 'control right',

    onClick: function() {
      this.controls.player.trigger('acorn-site');
    },

  });

  // ** player.views.controls.EditControl ** onClick : acorn website
  // ---------------------------------------------------------------------

  player.views.controls.EditControl = player.views.Control.extend({
    tooltip: 'Edit',

    id: 'edit',
    className: 'control right',

    onClick: function() {
      this.controls.player.trigger('show:edit');
    },

  });

  // ** player.views.controls.LeftControl ** onClick : acorn website
  // ---------------------------------------------------------------------

  player.views.controls.LeftControl = player.views.Control.extend({
    tooltip: 'Prev', // short as it doesn't fit for now :/

    id: 'left',
    className: 'control left',

    onClick: function() {
      this.controls.player.trigger('controls:left');
    },

  });

  // ** player.views.controls.RightControl ** onClick : acorn website
  // ---------------------------------------------------------------------

  player.views.controls.RightControl = player.views.Control.extend({
    tooltip: 'Next',

    id: 'right',
    className: 'control left',

    onClick: function() {
      this.controls.player.trigger('controls:right');
    },

  });

  // ** player.views.controls.ListControl ** onClick : acorn website
  // ---------------------------------------------------------------------

  player.views.controls.ListControl = player.views.Control.extend({
    tooltip: 'Playlist',

    id: 'list',
    className: 'control left',

    onClick: function() {
      this.controls.player.trigger('controls:list');
    },

  });

  // ** player.views.EditView ** a view to house all editing controls
  // ----------------------------------------------------------------

  player.views.EditView = PlayerSubview.extend({

    template: _.template('\
      <div class="row" id="toolbar">\
        <h1>acornid:<span id="acornid"></span></h1>\
        <div id="actions">\
          <button id="cancel" type="submit" class="btn">\
            <i class="icon-ban-circle"></i> Cancel\
          </button>\
          <button id="save" type="submit" class="btn btn-success">\
            <i class="icon-ok-circle icon-white"></i> Save\
          </button>\
          <div id="save-click-capture"></div>\
        </div>\
      </div>\
      <div id="form"></div>\
    '),

    id: 'edit',

    events: {
      'click button#cancel': 'onCancel',
      'click button#save': 'onSave',
    },

    initialize: function() {
      PlayerSubview.prototype.initialize.call(this);

      this.setShell(this.player.shell.clone());
    },

    setShell: function(shell) {

      if (this.shellView)
        this.shellView.remove();

      this.editingShell = shell;
      this.shellView = new shell.EditView({
        shell: this.editingShell,
      });

      // listen to the child view's edit state
      this.shellView.on('change:editState', this.onEditStateChange);

      // listen to the editing view's swap:shell event.
      // this will tell us when the shell data changes entire shell and
      // we need to reassign the shell and render the entire subview.
      this.shellView.on('swap:shell', this.onSwapShell);
      this.onEditStateChange();
    },

    render: function() {
      this.$el.empty();

      this.$el.html(this.template());
      this.$el.find('#acornid').text(this.player.model.acornid());

      if (this.shellView) {
        this.shellView.render();
        this.$el.find('#form').append(this.shellView.$el);
      }

      this.$el.find('#save-click-capture').tooltip({
        title: 'Finish editing<br/>before saving!',
        placement: 'bottom'
      });
    },

    onEditStateChange: function() {
      var save_btn = this.$el.find('#save');
      var save_click_capture = this.$el.find('#save-click-capture');
      if (this.shellView.isEditing()) {
        save_btn.attr('disabled', 'disabled');
        save_click_capture.show();
      } else {
        save_btn.removeAttr('disabled');
        save_click_capture.hide();
      }
    },

    onSwapShell: function(data) {
      var shell = acorn.shellWithData(data);
      this.setShell(shell);
      this.render();
    },

    onCancel: function() {
      this.player.trigger('close:edit');
    },

    onSave: function() {
      this.player.trigger('save:acorn');
    },
  });


  // ** player.Router ** routes requests
  // -----------------------------------

  player.Router = Backbone.Router.extend({

    routes: {
      '':                     'nothing',
      'player/new':           'new',
      'player/:acornid':      'acorn',
      ':catchall':            'nothing',
    },

    nothing: function() {
      this.navigate('player/what-is-acorn', {trigger: true});
    },

    new: function() {

      var acornModel = acorn('new');
      acornModel.shellData(new acorn.shells.MultiShell());

      this.showAcorn(acornModel);

      this.playerView.render();
      this.playerView.trigger('show:edit');

      this.playerView.editView.$el.find('#link input:first').focus();
    },

    acorn: function(acornid) {

      if (this.playerView && acornModel == this.playerView.model)
        return;

      var acornModel = acorn(acornid);
      this.showAcorn(acornModel);

      var self = this;
      this.playerView.model.fetch({
        success: function() { self.playerView.trigger('change:acorn'); },
        error: function() { self.playerView.error('failed to retrieve'); }
      });

    },

    showAcorn: function(acornModel) {

      this.playerView = new acorn.player.views.PlayerView({
        el: $('#acorn-player'),
        model: acornModel,
      });

      // give the playerView a handle to the router
      this.playerView.router = this;
      this.playerView.on('rename:acorn', _.bind(this.onRenamedAcorn, this));

      $('title').text('acorn:' + acornModel.acornid());

      acorn.player.instance = this.playerView;

    },

    onRenamedAcorn: function(acornid) {
      this.navigate('/player/' + acornid, {trigger: true});
    },

  });


}).call(this);
