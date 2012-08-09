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

  // Error out if backbone isn't present.
  if (_ == undefined)
    throw new Error('acorn.viewer.js requires Backbone.js');

  // Error out if backbone isn't present.
  if (Backbone == undefined)
    throw new Error('acorn.viewer.js requires Backbone.js');

  // Error out if EditbleTextCmp isn't present.
  if (Backbone.components.EditableTextCmp == undefined)
    throw new Error('acorn.viewer.js requires editabletext.js');

  // local handles
  var extend = acorn.util.extend;
  var extendPrototype = acorn.util.extendPrototype;
  var derives = acorn.util.derives;
  var UrlRegExp = acorn.util.UrlRegExp;
  var parseUrl = acorn.util.parseUrl;
  var iframe = acorn.util.iframe;
  var assert = acorn.util.assert;

  // Shells container
  acorn.shells = {};


  // **acorn.shellForLink** returns a shell to match given link
  // ----------------------------------------------------------

  acorn.shellForLink = function(link, options) {

    var location = parseUrl(link);

    // filter out shells that don't derive from LinkShell.
    var linkShells = _(acorn.shells).filter(function (shell) {
      return derives(shell, acorn.shells.LinkShell);
    });

    // filter out shells that don't match this link.
    var matchingShells = _(linkShells).filter(function (linkShell) {
      return linkShell.prototype.isValidLink(location);
    });

    // reduce to the most specific shell (in terms of inheritance).
    var bestShell = _(matchingShells).reduce(function(bestShell, shell) {
      return derives(bestShell, shell) ? bestShell : shell;
    }, acorn.shells.LinkShell);

    // if all else fails, use LinkShell.
    bestShell = bestShell || acorn.shells.LinkShell;

    // setup options
    options = _.extend({}, options);
    options.data = {'link': link};
    options.location = location;

    return new bestShell(options);
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


  // ShellView -- to be used by shells
  // ---------------------------------

  var ShellView = Backbone.View.extend({

    initialize: function() {
      this.shell = this.options.shell;
      assert(this.shell, 'No shell provided to shell ContentView.');
    },

  });

  // acorn.shells.Shell
  // ------------------

  var Shell = acorn.shells.Shell = function(options) {
    this.options = _.extend({}, (this.defaults || {}), options);
    this.data = _.extend({}, this.options.data); // make a copy.
    if (!this.data.shell)
      this.data.shell = this.shellid;
    assert(this.data.shell == this.shellid, "Shell data has incorrect type.");
  };

  // Set up all **Shell** prototype properties and methods.
  _.extend(Shell.prototype, Backbone.Events, {

    // The unique `shell` name of an acorn Shell.
    // The convention is to namespace by vendor. e.g. `acorn.Document`.
    shellid: 'acorn.Shell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'text',

    // The shell-specific control components to use.
    controls: [],

    // **thumbnailLink** returns the link to the thumbnail image
    // Override it with your own shell-specific render code.
    thumbnailLink: function() { return ''; },

    clone: function() {
      return new this.constructor(this.options);
    },

    ContentView: ShellView.extend({

      // class name
      className: 'acorn-shell',

      // aspect ratio. undefined if it doesn't matter.
      aspectRatio: undefined,
      adjustAspectRatio: function() {
        if (!this.aspectRatio)
          return;

        console.log('adjustAspectRatio to be implemented.');
      },

    }),

    EditView: ShellView.extend({

      className: 'acorn-shell-edit',

      // **template** defines the html template for this view.
      // Override to structure your own form.
      template: _.template(''),

      initialize: function() {
        ShellView.prototype.initialize.call(this);

        this.on('change:shell', this.onChangeShell);
      },

      // **render** renders the view.
      render: function() {
        this.$el.html(this.template());
      },

      onChangeShell: function() {
        // when the shell changes, re-render this view.
        this.render();
      },


    }),

  });

  // pass on the Backbone extend class inheritance function.
  Shell.extend = Backbone.Model.extend;

  // acorn.shells.LinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  var LinkShell = acorn.shells.LinkShell = Shell.extend({

    shellid: 'acorn.LinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'link',

    // **link** is the main data kept by LinkShells
    link: function(link) {
      if (link !== undefined)
        this.data.link = link;
      return this.data.link;
    },

    // **thumbnailLink** returns the link to the thumbnail image
    thumbnailLink: function(link) {
      if (link !== undefined)
        this.data.thumbnailLink = link;
      return this.data.thumbnailLink;
    },

    // ContentView -- Simply displays the link text for now.
    // TODO: thumbnail the website? embed the webpage in iframe?
    ContentView: acorn.shells.Shell.prototype.ContentView.extend({

      initialize: function() {
        Shell.prototype.ContentView.prototype.initialize.call(this);

        assert(this.shell.link, 'No link provided to LinkShell.');

        this.location = this.options.location || parseUrl(this.shell.link());

        assert(this.shell.isValidLink(this.location),
          'Link provided does not match ' + this.shell.type);

      },

      render: function() {

        var link = this.shell.link();
        var href = $('<a>').attr('href', link).text(link);
        this.$el.html(href);
      },

    }),

    // EditView -- a text field for the link.
    EditView: acorn.shells.Shell.prototype.EditView.extend({

      template: _.template('\
        <img id="thumbnail" />\
        <div class="thumbnailside">\
          <div id="link"></div>\
        </div>\
      '),

      initialize: function() {
        acorn.shells.Shell.prototype.EditView.prototype.initialize.call(this);
        _.bindAll(this);

        this.linkView = new Backbone.components.EditableTextCmp.View({
          textFn: this.link,
          placeholder: 'Enter Link',
          validate: _.bind(this.validateLink, this),
          addToggle: true,
          onSave: _.bind(this.onSave, this),
          onEdit: _.bind(this.onEdit, this),
        });

        this.isEditing_ = false;
      },

      validateLink: function(link) {
        if (acorn.util.isValidLink(link))
          return false;

        return "invalid link."
      },

      link: function(link) {
        if (link) {
          this.shell.link(link);
          var s = acorn.shellForLink(link, {shell: this.shell});

          // if the shellid has changed, we need to swap shells entirely.
          if (s.shellid != this.shell.data.shell)
            this.trigger('swap:shell', s.data);

          // else, announce that the shell has changed.
          else
            this.trigger('change:shell');
        }
        return this.shell.link();
      },

      render: function() {
        acorn.shells.Shell.prototype.EditView.prototype.render.call(this);

        // set thumbnail src
        var tlink = this.shell.thumbnailLink();
        this.$el.find('#thumbnail').attr('src', tlink);

        this.linkView.setElement(this.$el.find('#link'));
        this.linkView.render();

        if (!this.link())
          this.linkView.edit();
      },

      isEditing: function() {
        return this.isEditing_;
      },

      onSave: function() {
        var self = this;
        this.generateThumbnailLink(function(data) {
          self.shell.thumbnailLink(data);
          self.isEditing_ = false;
          self.trigger('change:editState');
          self.render();
        });
      },

      onEdit: function(){
        this.isEditing_ = true;
        this.trigger('change:editState');
      },

      generateThumbnailLink: function(callback) {
        var self = this;
        var bounds = '600x600';
        var req_url = '/url2png/' + bounds + '/' + this.shell.link();
        $.get(req_url, function(data) {
          callback(data);
        }).error(function() {
          alert('error generating url2png url (make this prettier)');
        });
      },

    }),


    // **validRegexes** list of valid LinkRegexes
    validRegexes: [
/\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i,
    ],

    // urlMatches: returns whether a given url matches this Shell.
    // determined by the validRegexes above.
    urlMatches: function(url) {
      return _(this.validRegexes).find(function(re) {
        return re.test(url);
      });
    },

    isValidLink: function(link) {
      return !!this.urlMatches(link);
    },

  });

  acorn.util.isValidLink =
    _.bind(LinkShell.prototype.isValidLink, LinkShell.prototype);

  // acorn.shells.ImageLinkShell
  // ---------------------------

  // A shell that links to media and embeds it.
  acorn.shells.ImageLinkShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.ImageLinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'image',

    // ContentView -- displays the image
    ContentView: acorn.shells.LinkShell.prototype.ContentView.extend({
      render: function() {
        var link = this.shell.link();
        var img = $('<img>').attr('src', link);
        this.$el.html(img);
      },
    }),

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

    // **validRegexes** list of valid LinkRegexes for images
    // .jpg, .png, .gif, etc.
    validRegexes: [
      UrlRegExp('.*(avi|mov|wmv)'),
    ],

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

      var re = this.urlMatches(link);
      assert(re, 'Incorrect youtube link, no video id found.');

      var videoid = re.exec(link)[3];
      return videoid;
    },

    embedLink: function() {
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

    // Overrides LinkShell.generateThumbnailLink()
    generateThumbnailLink: function(callback) {
      callback(this.thumbnailLink());
    },

    ContentView: acorn.shells.LinkShell.prototype.ContentView.extend({
      render: function() {
        var link = this.shell.embedLink();
        this.$el.append(iframe(link));
      },
    }),

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

      var re = this.urlMatches(link);
      assert(re, 'Incorrect vimeo link, no vimeo id found');

      var videoid = re.exec(link)[5];
      return videoid;
    },

    embedLink: function() {
      return 'http://player.vimeo.com/video/' + this.vimeoId()
           + '?byline=0'
           + '&portrait=0'
           ;
    },

    thumbnailLink: function() {
      return "https://img.youtube.com/vi/" + this.vimeoId() + "/0.jpg";
    },

    generateThumbnailLink: function(callback) {
      callback(this.thumbnailLink())
    },

    ContentView: acorn.shells.LinkShell.prototype.ContentView.extend({
      render: function() {
        var link = this.shell.embedLink();
        this.$el.append(iframe(link));
      },
    }),

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
