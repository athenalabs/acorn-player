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

  // Error out if backbone isn't present.
  if (_ == undefined)
    throw new Error('acorn.player.js requires Backbone.js');

  // Error out if backbone isn't present.
  if (Backbone == undefined)
    throw new Error('acorn.player.js requires Backbone.js');


  // local handles
  var extend = acorn.util.extend;


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

    initialize: function() {
      _.bindAll(this);

      // initialize with clean shell
      this.shell = undefined;

      // Subviews
      this.thumbnailView = new player.views.ThumbnailView({ player: this });
      this.controlsView = new player.views.ControlsView({ player: this });
      this.contentView = new player.views.ContentView({ player: this });

      this.on('change:acorn', this.onAcornChange);
      this.on('show:content', this.onShowContent);

      this.on('fullscreen', this.onFullscreen);
      this.on('acorn-site', this.onAcornSite);
    },

    render: function() {

      this.$el.empty();

      this.thumbnailView.render();
      this.$el.append(this.thumbnailView.el);
    },

    onAcornChange: function() {

      this.shell = acorn.shellWithAcorn(this.model);
      this.render();

    },

    onShowContent: function() {

      this.thumbnailView.$el.hide(1000);

      this.contentView.render();
      this.controlsView.render();

      this.$el.append(this.contentView.el);
      this.$el.append(this.controlsView.el);
    },

    triggerShowContent: function() {
      this.trigger('show:content');
    },

    onFullscreen: function() {
      console.log('fullscreen triggered');
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


  // ** player.views.ThumbnailView ** a view showing the acorn thumbnail
  // -------------------------------------------------------------------

  player.views.ThumbnailView = Backbone.View.extend({

    template: _.template('\
      <img id="image" src="" />\
      <img id="type" src="" class="thumbnail-icon" />\
      <img id="logo" src="" class="thumbnail-icon" />\
    '),

    id: 'thumbnail',

    initialize: function() {
      _.bindAll(this);

      this.player = this.options.player;
      if (!this.player)
        throw new acorn.errors.ParameterError('player');

    },

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

  player.views.ContentView = Backbone.View.extend({

    id: 'content',

    initialize: function() {
      _.bindAll(this);

      this.player = this.options.player;
      if (!this.player)
        throw new acorn.errors.ParameterError('player');

    },

    render: function() {

      this.$el.empty();

      this.player.shell.render();

      this.$el.append(this.player.shell.el);

    },

  });


  // control views.
  player.views.controls = {};


  // ** player.views.ControlsView ** view with media control buttons
  // ---------------------------------------------------------------

  player.views.ControlsView = Backbone.View.extend({

    id: 'controls',

    controls: [
      'AcornControl',
      'FullscreenControl',
    ],

    initialize: function() {
      _.bindAll(this);

      this.player = this.options.player;
      if (!this.player)
        throw new acorn.errors.ParameterError('player');

      this.player.on('change:acorn', this.onAcornChange);
    },

    render: function() {
      this.$el.empty();

      var self = this;
      _(this.controlViews).each(function(control) {
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

  });


  // ** player.views.Control ** superclass that all Controls inherit from
  // --------------------------------------------------------------------

  player.views.Control = Backbone.View.extend({

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

    },

    onClick: function() {

    },

  });

  // ** player.views.controls.FullscreenControl ** onClick : fulscreen
  // -----------------------------------------------------------------

  player.views.controls.FullscreenControl = player.views.Control.extend({

    id: 'fullscreen',
    className: 'control right',

    onClick: function() {
      this.controls.player.trigger('fullscreen');
    },

  });

  // ** player.views.controls.FullscreenControl ** onClick : acorn website
  // ---------------------------------------------------------------------

  player.views.controls.AcornControl = player.views.Control.extend({

    id: 'acorn',
    className: 'control right',

    onClick: function() {
      this.controls.player.trigger('acorn-site');
    },

  });


  // ** player.Router ** routes requests
  // -----------------------------------

  player.Router = Backbone.Router.extend({

    routes: {
      "":                     "nothing",
      "player/:acornid":       "acorn",
    },

    nothing: function() {
      this.navigate("player/what-is-acorn", {trigger: true});
    },

    acorn: function(acornid) {

      var playerView = acorn.player.instance;
      if (playerView && acornid == playerView.model.acornid()) {
        playerView.render();
        return;
      }

      playerView = new acorn.player.views.PlayerView({
        el: $('#acorn-player'),
        model: acorn(acornid),
      });

      playerView.model.fetch({
        success: function() { playerView.trigger('change:acorn'); },
        error: function() { playerView.error('failed to retrieve'); }
      });

      $('title').text('acorn:' + acornid);
    },

  });


  // onLoad entry point
  // ------------------

  $(document).ready(function() {

    // Initialize routing
    new acorn.player.Router();
    Backbone.history.start({pushState: true});

  });


}).call(this);
