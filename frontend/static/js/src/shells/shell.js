
// local handles
var extend = acorn.util.extend;
var extendPrototype = acorn.util.extendPrototype;
var derives = acorn.util.derives;
var UrlRegExp = acorn.util.UrlRegExp;
var parseUrl = acorn.util.parseUrl;
var iframe = acorn.util.iframe;
var assert = acorn.util.assert;

// Shell book-keeping.

// Shells container
acorn.shells = {};

// Shell registry -- shellid : shell mapping.
acorn.shellRegistry = {};

// Add given `shell` to shellRegistry.
acorn.registerShell = function (shell) {
  acorn.shellRegistry[shell.prototype.shellid] = shell;
};

// **acorn.shellWithData** Construct the right shell for given ``data``
// ----------------------------------------------------------------------

acorn.shellWithData = function(shellData) {

  var shell = _(acorn.shells).find(function (shell) {
    return shell.prototype.shellid == shellData.shell;
  });

  if (shell)
    return new shell({data: shellData});

  acorn.errors.UndefinedShellError(shellData.shell);

};


// **acorn.shellWithAcorn** Construct the right shell for given ``acorn``
// ----------------------------------------------------------------------

acorn.shellWithAcorn = function(acornModel) {
  return acorn.shellWithData(acornModel.shellData());
};


// acorn.shells.Shell
// ------------------

var Shell = acorn.shells.Shell = function(options) {
  this.options = _.extend({}, (this.defaults || {}), options);

  this.options.data = this.options.data || {};
  this.data = JSON.parse(JSON.stringify(this.options.data)); // copy

  if (!this.data.shell)
    this.data.shell = this.shellid;
  assert(this.data.shell == this.shellid, "Shell data has incorrect type.");
  this.shellClass = acorn.shellRegistry[this.shellid];
  this.initialize();
};


// ShellAPI - the interface _all_ shells must support.
// ---------------------------------------------------

var ShellAPI = {

  // The unique `shell` name of an acorn Shell.
  // The convention is to namespace by vendor. e.g. `acorn.Document`.
  shellid: 'acorn.Shell',

  // The cannonical type of this media. One of `acorn.types`.
  type: 'text',

  // The shell-specific control components to use.
  controls: [],

  // Defaults
  defaults: {
    autoplay: false, // whether playable media automatically starts playing.
  },

  // **initialize** overridable
  initialize: function() {},

  // **title** returns a simple title of the shell
  // Override it with your own shell-specific render code.
  title: function() { return ''; },

  // **description** returns a simple description of the shell
  // Override it with your own shell-specific render code.
  description: function() { return ''; },

  // **thumbnailLink** returns the link to the thumbnail image
  // Override it with your own shell-specific render code.
  thumbnailLink: function() { return ''; },

  clone: function() {
    return new this.constructor(this.options);
  },

  // **shellClass** return the constructor object corresponding to this shell.
  shellClass: this,

};


// Set up all **Shell** prototype properties and methods.
_.extend(Shell.prototype, Backbone.Events, ShellAPI);

// pass on the Backbone extend class inheritance function.
Shell.extend = Backbone.Model.extend;



// ShellView -- to be used by shells
// ---------------------------------

var ShellView = Shell.ShellView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this);
    this.shell = this.options.shell;
    this.parent = this.options.parent;

    assert(this.shell, 'No shell provided to ShellView.');
    assert(this.parent, 'No parent provided to ShellView')
  },

  // **isSubShellView** whether this shellview is the child of another
  isSubShellView: function() {
    // ShellViews have the ``isSubShellView`` property.
    return this.parent.isSubShellView !== undefined;
  },

});


// Shell.ContentView -- user-facing shell display
// ----------------------------------------------


// acorn Player:
//
// ------------------------------------------------------------------
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                       Content Shell                            |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// |                                                                |
// ------------------------------------------------------------------
// |                       Player Controls                          |
// ------------------------------------------------------------------


Shell.ContentView = ShellView.extend({

  // class name
  className: 'acorn-shell',

  initialize: function() {
    ShellView.prototype.initialize.call(this);

    this.parent.on('playback:play', this.onPlaybackPlay);
    this.parent.on('playback:stop', this.onPlaybackStop);
  },

  remove: function() {
    this.parent.off('playback:play', this.onPlaybackPlay);
    this.parent.off('playback:stop', this.onPlaybackStop);

    ShellView.prototype.remove.call(this);
  },

  // aspect ratio. undefined if it doesn't matter.
  aspectRatio: undefined,
  adjustAspectRatio: function() {
    if (!this.aspectRatio)
      return;

    console.log('adjustAspectRatio to be implemented.');
  },


  // events that all shells should have?
  // onLoseFocus: function () {},
  // onGainFocus: function () {},
  onPlaybackPlay: function () {},
  onPlaybackStop: function () {},

});

// Shell.SummaryView -- uniform view to summarize a shell.
// -------------------------------------------------------

// +-----------+
// |           |   Title of This Wonderful Shell
// |   thumb   |   A short description of this particular shell.
// |           |   [ action ] [ action ] ...
// +-----------+
//
// The actions are buttons that vary depending on the use-case of the
// SummaryView. The title and description are now overridable functions
// in Shell.

Shell.SummaryView = ShellView.extend({

  // class name
  className: 'acorn-shell-summary',

  template: _.template('\
    <img id="thumbnail" />\
    <div class="thumbnailside">\
      <div id="title"></div>\
      <div id="description"></div>\
      <div id="buttons"></div>\
    </div>\
  '),

  render: function() {

    this.$el.empty();
    this.$el.html(this.template());

    var title = this.shell.title();
    var desc = this.shell.description();

    this.$el.find('#title').text(title);
    this.$el.find('#description').text(desc);

    var thumbnailLink = this.shell.thumbnailLink();
    this.$el.find('#thumbnail').attr('src', thumbnailLink);
  },

});


// Shell.EditView -- uniform view to edit shell data.
// --------------------------------------------------

Shell.EditView = ShellView.extend({

  className: 'acorn-shell-edit',

  // Supported trigger events
  // * swap:shell - fired when shell type has changed
  // * change:shell - fired when shell data has changed
  // * change:editState - fired when EditView changes editing state

  // **template** defines the html template for this view.
  // Override to structure your own form.
  template: _.template(''),

  initialize: function() {
    ShellView.prototype.initialize.call(this);

    this.on('change:shell', this.onChangeShell);
    this.on('swap:shell', this.onSwapShell);
  },

  // **isEditing** is a property function in order to be overridable
  isEditing: acorn.util.property(false),

  // **shouldSave** is a property function in order to be overridable
  // shouldSave can prevent saves from happening. This is useful when
  // swapping shells. Swapped-out ``shell.EditView`` should not save.
  shouldSave: acorn.util.property(false),

  // **render** renders the view.
  render: function() {
    this.$el.html(this.template());
  },

  onChangeShell: function() {
    // when the shell changes, re-render this view.
    this.render();
  },

  onSwapShell: function() {
    this.shouldSave(false);
  },

  // **finalizeEdit** finish all edits.
  finalizeEdit: function() {},

});


// Register the shell with the acorn object.
acorn.registerShell(Shell);
