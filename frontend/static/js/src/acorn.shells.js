//     acorn.js 0.0.0
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


  // Error out if acorn isn't present.
  if (acorn == undefined)
    throw new Error('acorn.lib.js requires acorn.js');

  // local handles
  var extend = acorn.util.extend;
  var extendPrototype = acorn.util.extendPrototype;
  var UrlRegExp = acorn.util.UrlRegExp;
  var parseUrl = acorn.util.parseUrl;
  var iframe = acorn.util.iframe;

  // Shells container
  acorn.shells = {};


  // acorn.shells.Shell
  // ------------------

  // A module that outlines the interface for all media types.
  acorn.shells.Shell = Backbone.View.extend({

    // The unique `shell` name of an acorn Shell.
    // The convention is to namespace by vendor. e.g. `acorn.Document`.
    shellid: 'acorn.Shell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'text',

    // The shell-specific control components to use.
    controls: [],

    // class name
    className: 'acorn-shell',

    // **initialize** is an empty function by default.
    // Override it with your own initialization logic.
    initialize: function() {
      this.data = this.model.shell();
    },

    // **contentTemplate** is the html template for shell content.
    contentTemplate: '',

    // **controlsTemplate** shell specific controls
    controlsTemplate: '',

    // aspect ratio. undefined if it doesn't matter.
    aspectRatio: undefined,
    adjustAspectRatio: function() {
      if (!this.aspectRatio)
        return;

      console.log('adjustAspectRatio to be implemented.');
    },

    // render
    render: function() {
      this.$el.empty();
      this.renderContent();
      this.renderControls();
      this.adjustAspectRatio();
    },

    // **renderContent** is an empty function by default.
    // Override it with your own shell-specific render code.
    renderContent: function() {},

    // **renderControls** is an empty function by default.
    // Override it with your own shell-specific render code.
    renderControls: function() {},

    // **thumbnailLink** returns the link to the thumbnail image
    // Override it with your own shell-specific render code.
    thumbnailLink: function() { return ''; },

  }, {

    withAcorn: function(acornModel) {
      var shellData = acornModel.shell();
      for (var i in acorn.shells) {
        var shell = acorn.shells[i];
        if (shell.prototype.shellid == shellData.shell)
          return new shell({model: acornModel});
      }
      acorn.errors.UndefinedShellError(shellData.shell);
    },

  });

  // shorthand for quick-shell construction.
  acorn.shellWithAcorn = acorn.shells.Shell.withAcorn;


  // acorn.shells.LinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.LinkShell = acorn.shells.Shell.extend({

    shellid: 'acorn.LinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'link',

    initialize: function() {
      acorn.shells.Shell.prototype.initialize.call(this);

      if (!this.data.link)
        throw new Error('No link provided to LinkShell.');

      this.location = this.options.location || parseUrl(this.data.link);

      if (!this.constructor.urlMatches(this.location))
        throw new Error('Link provided does not match LinkShell.');

    },

    link: function() {
      return this.data.link;
    },

    renderContent: function() {
      var link = this.link();
      var href = $('<a>').attr('href', link).text(link);
      this.$el.append(href);
    },


  }, {

    // **validRegexes** list of valid LinkRegexes
    validRegexes: [
    // from the web
/\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i,
    ],

    // urlMatches: returns whether a given url matches this Shell.
    // determined by the validRegexes above.
    urlMatches: function(url) {

      for (var i in this.validRegexes) {
        var re = this.validRegexes[i];
        if (re.test(url.href))
          return true;
      }

      return false;
    },

    isValidLink: function(link) {
      return this.urlMatches(link);
    },

    classify: function(link, options) {

      var location = parseUrl(link);

      var bestShell = undefined;
      for (var i in acorn.shells) {
        var shell = acorn.shells[i];

        // skip shells that do not derive from LinkShell
        if (!shell.derives || !shell.derives(acorn.shells.LinkShell))
          continue;

        // Skip parents of the bestShell so far (already more specific)
        if (bestShell && bestShell.derives(shell))
          continue;

        if (shell.urlMatches(location))
          bestShell = shell;
      }

      options = options || {};
      options.data = {'link': link};
      options.location = location;
      return new (bestShell || acorn.shells.LinkShell)(options);
    },


  });
  acorn.shellWithLink = acorn.shells.LinkShell.classify;

  // acorn.shells.ImageLinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.ImageLinkShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.ImageLinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'image',

    // **renderVars** returns the variables for the render template.
    renderContent: function() {
      var link = this.link();
      var img = $('<img>').attr('src', link);
      this.$el.append(img);
    },

    // **thumbnailLink** returns the link to the thumbnail image
    thumbnailLink: function() {
      return this.link();
    },

  }, {

    // **validRegexes** list of valid LinkRegexes for images
    // .jpg, .png, .gif, etc.
    validRegexes: [
      UrlRegExp('.*(jpg|jpeg|gif|png|svg)'),
    ],

  });

  // acorn.shells.VideoLinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.VideoLinkShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.VideoLinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

  }, {

    // **urlMatches** returns whether a given link points to a video
    // .wmv, .mov, .avi, etc.
    urlMatches: function(url) {

      switch (url.extension) {
        case 'avi':
        case 'mov':
        case 'wmv':
          return true;
      }

      return false;
    },

  });


  // acorn.shells.YouTubeShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.YouTubeShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.YouTubeShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

    // **youtubeId** returns the youtube video id of this link.
    youtubeId: function() {
      var link = this.link();

      for (var i in this.constructor.validRegexes) {
        var re = this.constructor.validRegexes[i];
        if (!re.test(link))
          continue;

        var videoid = re.exec(link)[3];
        return videoid;
      }

      throw new Error('Incorrect youtube link, no video id found.');
    },

    embeddableLink: function() {
      return 'https://www.youtube.com/embed/' + this.youtubeId()
           + '?fs=1'
           // + '&modestbranding=1'
           + '&iv_load_policy=3'
           + '&rel=0'
           + '&showsearch=0'
           + '&hd=1'
           + '&wmode=transparent'
           + '&autoplay=1'
           ;
    },

    // **thumbnailLink** returns the link to the thumbnail image
    thumbnailLink: function() {
      return "https://img.youtube.com/vi/" + this.youtubeId() + "/0.jpg";
    },

    renderContent: function() {
      var link = this.embeddableLink();
      this.$el.append(iframe(link))
    },

  }, {

    // **validRegexes** list of valid LinkRegexes
    validRegexes: [
      UrlRegExp('(www\.)?youtube\.com\/v\/([A-Za-z0-9\-_]+).*'),
      UrlRegExp('(www\.)?youtube\.com\/embed\/([A-Za-z0-9\-_]+).*'),
      UrlRegExp('(www\.)?youtube\.com\/watch\?.*v=([A-Za-z0-9\-_]+).*'),
      UrlRegExp('(www\.)?y2u.be\/([A-Za-z0-9\-_]+)'),
    ],

  });

  // acorn.shells.VimeoShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.VimeoShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.VimeoShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

    // **vimeoId** returns the youtube video id of this link.
    vimeoId: function() {
      var link = this.link();

      for (var i in this.constructor.validRegexes) {
        var re = this.constructor.validRegexes[i];
        if (!re.test(link))
          continue;

        var videoid = re.exec(link)[5];
        return videoid;
      }

      throw new Error('Incorrect vimeo link, no video id found.');
    },

    embeddableLink: function() {
      return 'http://player.vimeo.com/video/' + this.vimeoId()
           + '?byline=0'
           + '&portrait=0'
           ;
    },

    thumbnailLink: function() {
      return "https://img.youtube.com/vi/" + this.vimeoId() + "/0.jpg";
    },

    renderContent: function() {
      var link = this.embeddableLink();
      this.$el.append(iframe(link))
    },

  }, {

    // **validRegexes** list of valid LinkRegexes
    validRegexes: [
      UrlRegExp('(www\.)?(player\.)?vimeo\.com\/(video\/)?([0-9]+).*'),
    ],

  });



  // Add each shell to the registry under its shellid.
  _.each(acorn.shells, function(shell) {
    acorn.shells[shell.prototype.shellid] = shell;
  });


}).call(this);
