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
      _.bindAll(this);
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
    this.initialize();
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

    ContentView: ShellView.extend({

      // class name
      className: 'acorn-shell',

      initialize: function() {
        ShellView.prototype.initialize.call(this);

        this.options.parent.on('playback:play', this.onPlaybackPlay);
        this.options.parent.on('playback:stop', this.onPlaybackStop);
      },

      remove: function() {
        this.options.parent.off('playback:play', this.onPlaybackPlay);
        this.options.parent.off('playback:stop', this.onPlaybackStop);

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

    }),

    SummaryView: ShellView.extend({

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

    }),

    EditView: ShellView.extend({

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

      // called when EditView saves
      onSave: function() {
        if (!this.shouldSave())
          return; // bail out if we shouldn't save

        this.isEditing(false);
        this.shouldSave(false);
        this.trigger('change:editState');
        this.render();
      },

      // called when EditView begins editing state
      onEdit: function() {
        this.isEditing(true);
        this.shouldSave(true);
        this.trigger('change:editState');
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

    // **title** returns a simple title of the shell
    title: function() { return this.link(); },

    // **description** returns a simple description of the shell
    description: function() { return ''; },

    // **thumbnailLink** returns the link to the thumbnail image
    thumbnailLink: function(link) {
      if (link !== undefined)
        this.data.thumbnailLink = link;
      return this.data.thumbnailLink;
    },

    extraInfoLink: function() { return ''; },

    // Retrieve extra information. Nothing by default.
    retrieveExtraInfo: function(callback) {
      callback = callback || function() {};

      var extraInfoLink = this.extraInfoLink();
      if (!extraInfoLink || this.extraInfo) {
        return callback();
      }

      var self = this;
      $.getJSON(extraInfoLink, function(data) {
        self.extraInfo = data;
        callback();
      });
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
        this.$el.append(iframe(link, 'link-iframe'));
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

        this.linkView = new Backbone.components.EditableTextCmp.View({
          textFn: this.link,
          placeholder: 'Enter Link',
          validate: _.bind(this.validateLink, this),
          addToggle: true,
          onSave: _.bind(this.onSave, this),
          onEdit: _.bind(this.onEdit, this),
        });

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
            this.trigger('change:shell', this.shell);
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

      onSave: function() {
        if (!this.shouldSave())
          return; // bail out if we shouldn't save

        var self = this;
        this.generateThumbnailLink(function(data) {
          self.shell.thumbnailLink(data);

          // call super class onSave
          acorn.shells.Shell.prototype.EditView.prototype.onSave.call(self);
        });
      },

      generateThumbnailLink: function(callback) {
        var self = this;
        var bounds = '600x600';
        var req_url = '/url2png/' + bounds + '/' + this.shell.link();
        $.ajax(req_url, {
          success: function(data) {
            callback(data);
          },
          error: function() {
            acorn.alert('Error: failed to generate thumbnail for link.',
                        'alert-error');
          }
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
      UrlRegExp('.*\.(jpg|jpeg|gif|png|svg)'),
    ],

  });

  // acorn.shells.VideoLinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.VideoLinkShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.VideoLinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

    // **validRegexes** list of valid LinkRegexes for videos
    // .avi, .mov, .wmv, etc.
    validRegexes: [
      UrlRegExp('.*\.(avi|mov|wmv)'),
    ],

    // **description** returns a simple description of the shell
    description: function() {
      return 'Seconds ' + this.data.time_start
           + ' to ' + this.data.time_end
           + ' of video';
    },

    duration: function() { return this.data.time_end || 0; },

    // ContentView -- displays the video
    ContentView: acorn.shells.LinkShell.prototype.ContentView.extend({

      render: function() {
        this.$el.empty();

        // stop ticking, in case we had been playing and this is a re-render.
        this.stopTick();
      },

      remove: function() {
        this.stopTick(); // stop the interval on remove.

        acorn.shells.LinkShell
          .prototype.ContentView
          .prototype.remove
          .call(this);
      },


      // VideoLinkShell.ContentView interface -- override these in subclasses
      // --------------------------------------------------------------------

      // -- Information:

      // the total duration in seconds
      totalTime: function() { return 0; },

      // the current playback position in seconds
      currentTime: function() { return 0; },

      // whether the video is currently playing
      isPlaying: function() { return false; },

      // -- Actions:

      // begins playing the video (idempotent)
      play: function() {},

      // stops playing the video (idempotent)
      stop: function() {},

      // seeks to the specific offset in seconds
      seek: function(seconds) {},


      // shell.ContentView events
      // ------------------------

      onPlaybackStop: function() {
        this.stop();
      },

      onPlaybackPlay: function() {
        this.play();
      },


      // Playback Tick - trigger a callback at a given interval during playback
      // ----------------------------------------------------------------------

      // start the interval
      startTick: function() {
        this.stopTick();
        this.interval = setInterval(this.onTick, 200);
      },

      // clear the interval
      stopTick: function() {
        if (this.interval) {
          clearInterval(this.interval);
          this.interval = undefined;
        }
      },

      // tick callback
      onTick: function() {
        // get shell options
        var loop = this.shell.data.loop || false;
        var end = this.shell.data.time_end || this.totalTime();
        var start = this.shell.data.time_start || 0;

        // get current state
        var now = this.currentTime();
        var playing = this.isPlaying();

        // if current playback is behind the start time, seek to start
        if (playing && now < start) {
          this.seek(start);
        }

        // if current playback is after the end time, pause (or loop)
        if (playing && now >= end) {
          if (loop) {
            this.seek(start);
          } else {
            this.stop();
          }
        }
      },


    }),

    EditView: acorn.shells.LinkShell.prototype.EditView.extend({

      events: {
        'change input':  'timeInputChanged',
        'blur input':  'timeInputChanged',
      },

      timeRangeTemplate: _.template('\
      <div id="slider" class="fader"></div>\
      <form class="form-inline">\
        <div class="input-prepend">\
          <span class="add-on">start:</span>\
          <input id="start" size="16" type="text" class="time">\
          <!--<span class="add-on">sec</span>-->\
        </div>\
        <div class="input-prepend">\
          <span class="add-on">end:</span>\
          <input id="end" size="16" type="text" class="time">\
          <!--<span class="add-on">sec</span>-->\
        </div>\
        <span id="time"></span>\
        <label class="checkbox right" id="loop-label">\
          <input id="loop" type="checkbox"> Loop\
        </label>\
      </form>\
      '),

      render: function() {
        acorn.shells.LinkShell.prototype.EditView.prototype.render.call(this);

        var timeRange = $(this.timeRangeTemplate());

        // update with the correct values.
        if (this.shell.data.loop)
          timeRange.find('#loop').attr('checked', 'checked');

        this.$el.find('.thumbnailside').append(timeRange);
        this.$el.find('#slider').css('opacity', '0.0');
        this.setupSlider();

        this.shell.retrieveExtraInfo(_.bind(function() {
          this.setupSlider();
          this.$el.find('#slider').css('opacity', '1.0');
        }, this));
      },

      setupSlider: function() {
        var data = this.shell.data;

        var max = this.shell.duration();

        // setup slider
        var self = this;
        this.$el.find('#slider').slider('destroy');
        this.$el.find('#slider').slider({
          min: 0,
          max: max,
          range: true,
          values: [ data.time_start || 0, data.time_end || max],
          slide: function(e, ui) { self.inputChanged(ui.values); },
        });

        this.inputChanged([ data.time_start, data.time_end ]);

      },

      timeInputChanged: function() {
        this.inputChanged([
          this.$el.find('#start').val(),
          this.$el.find('#end').val()
        ]);
      },

      inputChanged: function(values) {
        clip = function(min, _, max) {
          return Math.max(min, Math.min(_ || 0, max));
        }

        var max = this.shell.data.time_total || this.shell.duration();
        var start = clip(0, parseInt(values[0]), values[1]) || 0;
        var end = clip(start, parseInt(values[1]), max) || max;
        var loop = !!this.$el.find('#loop').attr('checked');

        var diff = (end - start);
        var time = (isNaN(diff) ? '--' : diff) + ' seconds';

        this.shell.data.time_start = start;
        this.shell.data.time_end = end;
        this.shell.data.loop = loop;

        this.$el.find('#start').val(start);
        this.$el.find('#end').val(end);
        this.$el.find('#time').text(time);
        this.$el.find('#slider').slider({ max: max, values: [start, end] });
      },

    }),

  });


  // acorn.shells.YouTubeShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.YouTubeShell = acorn.shells.VideoLinkShell.extend({

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
      // see https://developers.google.com/youtube/player_parameters for options
      return 'http://www.youtube.com/embed/' + this.youtubeId() + '?'
           + '&fs=1'
           // + '&modestbranding=1'
           + '&iv_load_policy=3'
           + '&rel=0'
           + '&showsearch=0'
           + '&showinfo=0'
           + '&hd=1'
           + '&wmode=transparent'
           + '&enablejsapi=1'
           + '&controls=1'
           ;
    },

    // **thumbnailLink** returns the link to the thumbnail image
    thumbnailLink: function() {
      return "https://img.youtube.com/vi/" + this.youtubeId() + "/0.jpg";
    },


    extraInfoLink: function() {
      return 'http://gdata.youtube.com/feeds/api/videos/' + this.youtubeId()
           + '?v=2'
           + '&alt=jsonc';
    },

    // **title** returns a simple title of the shell
    title: function() {
      return this.extraInfo ? this.extraInfo.data.title : this.link();
    },

    // **description** returns a simple description of the shell
    description: function() {
      return 'Seconds ' + (this.data.time_start || 0)
           + ' to ' + (this.data.time_end || this.duration())
           + ' of YouTube video '
           + this.link();
    },

    duration: function() {
      return this.extraInfo ? this.extraInfo.data.duration : this.data.time_end;
    },

    ContentView: acorn.shells.VideoLinkShell.prototype.ContentView.extend({

      render: function() {
        acorn.shells.VideoLinkShell
          .prototype.ContentView
          .prototype.render
          .call(this);

        // initialize YouTube setup.
        this.onYTInitialize();

        // add the YouTube player iframe
        var link = this.shell.embedLink();
        this.$el.append(iframe(link, 'ytplayer'));
      },


      // YouTube API - communication between the YouTube js API and the shell.
      // ---------------------------------------------------------------------
      // see https://developers.google.com/youtube/js_api_reference

      // the javascript file with the youtube player api.
      youtubePlayerApiSrc: 'http://www.youtube.com/iframe_api',

      // initialize youtube API
      onYTInitialize: function() {
        // initialization should only happen once per page load.

        // if YT hasn't been initialized, initialize it.
        if (!window.onYouTubeIframeAPIReady) {

          // setup YT ready callback
          window.onYouTubeIframeAPIReady = this.onYTReady;

          // include the YouTubePlayerAPI code
          var script = $('<script>').attr('src', this.youtubePlayerApiSrc);
          $('body').append(script);

          return; // onYTReady will be called when YT finishes initializing
        }

        // must call onYTReady once the current render call stack finishes
        // because the frame is not yet on the page. YT API expects the id
        // of a player currently on the page. Backbone has yet to add the
        // current DOM subtree to the page DOM. setTimeout will schedule
        // the callback after the current stack finishes.
        setTimeout(this.onYTReady, 0);
      },

      // The YT API is ready for use
      onYTReady: function() {

        // initialize the `ytplayer` object
        this.ytplayer = new YT.Player('ytplayer', {
          events: {
            'onReady': this.onYTPlayerReady,
            'onStateChange': this.onYTPlayerStateChange,
          }
        });

        // clear the callback function, but set empty function:
        // * in case the callback gets called again
        // * to signal YT has already been initialized
        window.onYouTubeIframeAPIReady = function() {};
      },

      onYTPlayerReady: function() {

        // tell `ytplayer` to load the video, with given start time.
        // this *should* initialize the playback at the correct point,
        // but in practice it doesn't. Need a robust solution (tick).
        var start = parseInt(this.shell.data.time_start || 0);

        if (this.options.autoplay) {
          this.ytplayer.loadVideoById(this.shell.youtubeId(), start);
        } else {
          this.ytplayer.cueVideoById(this.shell.youtubeId(), start);
          this.play();
        }
      },

      onYTPlayerStateChange: function(event) {
        var state = event.data;
        // ``event.data`` ought to equal ``this.ytplayer.getPlayerState()``.
        // I'm using ``event.data`` here in case events get fired from other
        // YouTube Players?? Seems safer to trust the function paramters.

        if (state == YT.PlayerState.PLAYING)
          this.startTick();
        else
          this.stopTick();
      },


      // VideoLinkShell.ContentView interface -- overriding with native impl
      // -------------------------------------------------------------------

      // -- Information:

      // the total duration in seconds
      totalTime: function() {
        return this.ytplayer.getDuration() || Infinity;
      },

      // the current playback position in seconds
      currentTime: function() {
        return this.ytplayer.getCurrentTime();
      },

      // whether the video is currently playing
      isPlaying: function() {
        if (!this.ytplayer)
          return false;

        var state = this.ytplayer.getPlayerState();
        return (state == YT.PlayerState.PLAYING);
      },

      // -- Actions:

      // begins playing the video (idempotent)
      play: function() {
        this.ytplayer.playVideo();
      },

      // stops playing the video (idempotent)
      stop: function() {
        this.ytplayer.pauseVideo();
      },

      // seeks to the specific offset in seconds
      seek: function(seconds) {
        this.ytplayer.seekTo(seconds, true);
      },

    }),

    EditView: acorn.shells.VideoLinkShell.prototype.EditView.extend({
      // Overrides LinkShell.generateThumbnailLink()
      generateThumbnailLink: function(callback) {
        callback(this.shell.thumbnailLink());
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
  acorn.shells.VimeoShell = acorn.shells.VideoLinkShell.extend({

    shellid: 'acorn.VimeoShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

    // **vimeoId** returns the vimeo video id of this link.
    vimeoId: function() {
      var link = this.link();

      var re = this.urlMatches(link);
      assert(re, 'Incorrect vimeo link, no vimeo id found');

      var videoid = re.exec(link)[5];
      return videoid;
    },

    embedLink: function() {
      // see http://developer.vimeo.com/player/embedding
      return 'http://player.vimeo.com/video/' + this.vimeoId() + '?'
           + '&byline=0'
           + '&portrait=0'
           + '&api=1'
           + '&player_id=vimeoplayer'
           + '&title=0'
           + '&byline=1'
           + '&portrait=0'
           + '&color=ffffff'
           ;
    },

    extraInfoLink: function() {
      return 'http://vimeo.com/api/v2/video/' + this.vimeoId() + '.json?'
           + '&callback=?' // somehow allows cross-domain requests.
           ;
    },

    // **title** returns a simple title of the shell
    title: function() {
      return this.extraInfo ? this.extraInfo[0].title : this.link();
    },

    // **description** returns a simple description of the shell
    description: function() {
      return 'Seconds ' + (this.data.time_start || 0)
           + ' to ' + (this.data.time_end || this.duration())
           + ' of Vimeo video '
           + this.link();
    },

    duration: function() {
      return this.extraInfo ? this.extraInfo[0].duration : this.data.time_end;
    },

    ContentView: acorn.shells.VideoLinkShell.prototype.ContentView.extend({

      render: function() {
        this.$el.empty();

        // stop ticking, in case we had been playing and this is a re-render.
        this.stopTick();

        // initialize YouTube setup.
        this.onVimeoInitialize();

        // add the Vimeo player iframe
        var link = this.shell.embedLink();
        this.$el.append(iframe(link, 'vimeoplayer'));
      },

      // Vimeo API - communication between the Vimeo js API and the shell.
      // -----------------------------------------------------------------
      // see http://developer.vimeo.com/player/js-api

      // the javascript file with the youtube player api.
      vimeoPlayerApiSrc: 'http://a.vimeocdn.com/js/froogaloop2.js',

      // initialize youtube API
      onVimeoInitialize: function() {
        // initialization should only happen once per page load.

        // if Vimeo hasn't been initialized, initialize it.
        if (!window.$f) {
          $.getScript(this.vimeoPlayerApiSrc, this.onVimeoReady);
          return;
        }

        // must call onVimeoReady once the current render call stack finishes
        // because the frame is not yet on the page. Vimeo API expects the id
        // of a player currently on the page. Backbone has yet to add the
        // current DOM subtree to the page DOM. setTimeout will schedule
        // the callback after the current stack finishes.
        setTimeout(this.onVimeoReady, 0);
      },

      // The Vimeo API is ready for use
      onVimeoReady: function() {

        // initialize the `vimeoPlayer` object
        var frame = this.$el.find('#vimeoplayer');
        this.vimeoPlayer = $f(frame[0]);

        this.vimeoPlayer.addEvent('ready', this.onVimeoPlayerReady);

      },

      onVimeoPlayerReady: function() {

        // attach the callbacks to the vimeo player.
        this.vimeoPlayer.addEvent('pause', this.onVimeoPause);
        this.vimeoPlayer.addEvent('play', this.onVimeoPlay);
        this.vimeoPlayer.addEvent('playProgress', this.onVimeoPlayProgress);

        this.play();
      },

      onVimeoPause: function() {
        this._isplaying = false;
      },

      onVimeoPlay: function() {
        this._isplaying = true;
      },

      onVimeoPlayProgress: function(params) {
        this._totalTime = parseFloat(params.duration);
        this._currentTime = parseFloat(params.seconds);
        this._isplaying = true;

        // use vimeo's interval callback -- call onTick manually.
        this.onTick();
      },

      // override {start,stop}Tick, as Vimeo has it's own interval callback.
      startTick: function() {},
      stopTick: function() {},

      // VideoLinkShell.ContentView interface -- overriding with native impl
      // -------------------------------------------------------------------

      // -- Information:

      // the total duration in seconds
      totalTime: function() {
        return this._totalTime || Infinity;
      },

      // the current playback position in seconds
      currentTime: function() {
        return this._currentTime || 0;
      },

      // whether the video is currently playing
      isPlaying: function() {
        return this._isplaying || false;
      },

      // -- Actions:

      // begins playing the video (idempotent)
      play: function() {
        this.vimeoPlayer.api('play');
      },

      // stops playing the video (idempotent)
      stop: function() {
        this.vimeoPlayer.api('pause');
      },

      // seeks to the specific offset in seconds
      seek: function(seconds) {
        // console.log('seekTo ' + seconds);
        this.vimeoPlayer.api('seekTo', [seconds.toString()]);
      },

    }),

    EditView: acorn.shells.VideoLinkShell.prototype.EditView.extend({
      // Overrides LinkShell.generateThumbnailLink()
      generateThumbnailLink: function(callback) {
        // TODO(ali01) use retrieveExtraInfo?

        // This would be the code. It works, and it leverages the fact
        // that ``retrieveExtraInfo`` already has to be called for the
        // duration. I think if we fix things away from $.getJSON we'd
        // do it in retrieveExtraInfo, so I think this below should be
        // what actually generates the thumbnail.

        // this.shell.retrieveExtraInfo(_.bind(function() {
        //   callback(this.shell.extraInfo[0].thumbnail_large);
        // }, this));

        var url_req = '/request_proxy/vimeo.com/api/v2/video/' +
                      this.shell.vimeoId() + '.json';
        $.ajax(url_req, {
          success: function(data) {
            try {
              callback(data[0].thumbnail_large);
            } catch(e) {
              acorn.alert('Error: failed to extract thumbnail from video.',
                          'alert-error');
            }
          },
          error: function() {
            acorn.alert('Error: failed to generate thumbnail for video.',
                        'alert-error');
          }
        });
      },
    }),

    // **validRegexes** list of valid LinkRegexes
    validRegexes: [
      UrlRegExp('(www\.)?(player\.)?vimeo\.com\/(video\/)?([0-9]+).*'),
    ],

  });


  // acorn.shells.PDFLinkShell
  // ----------------------
  acorn.shells.PDFLinkShell = acorn.shells.LinkShell.extend({

    shellid: 'acorn.PDFLinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'document',

    // **validRegexes** regex to match links to PDFs
    validRegexes: [
      UrlRegExp('.*\.pdf'),
    ],

    EditView: acorn.shells.LinkShell.prototype.EditView.extend({
      // Overrides LinkShell.generateThumbnailLink()
      generateThumbnailLink: function(callback) {
        callback('/static/img/thumbnails/pdf.png');
      },
    }),
  });



  // acorn.shells.MultiShell
  // -----------------------

  // A shell that contains other shells
  acorn.shells.MultiShell = Shell.extend({

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

      this.data.shells = this.data.shells || {};
    },

    // **title** returns a simple title of the shell
    title: function() {
      var items = _.keys(this.data.shells).length;
      var s = (items == 1 ? '' : 's');
      return 'playlist with ' + items + ' item' + s;
    },

    ContentView: acorn.shells.Shell.prototype.ContentView.extend({

      // **shellViews** is a container for sub shellViews.
      shellViews: [],

      // Supported trigger events
      //
      // * change:subview - fired when subview currently show changes.

      initialize: function() {
        Shell.prototype.ContentView.prototype.initialize.call(this);

        // controls
        this.options.parent.on('controls:left', this.onShowPrevious);
        this.options.parent.on('controls:list', this.onShowPlaylist);
        this.options.parent.on('controls:right', this.onShowNext);

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
          return new shell.ContentView({
            shell: shell,
            parent: this,
            autoplay: true,
          });
        }, this);

        // clean up our elem
        this.$el.empty();

        this.showView(0)
      },

      currentViewIndex: function() {
        return _.indexOf(this.shellViews, this.currentView);
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
        var playlistId = this.shell.PlaylistView.prototype.id;
        if (this.$el.find('#' + playlistId).length > 0)
          return;

        var playlistView = new this.shell.PlaylistView({
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
        var contentView = this.options.parent;
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


      // helper to map `func` through `shellViews` with `this` as context
      map: function(func) {
        _.map(this.shellViews, func, this);
      },

    }),

    // **PlaylistView** - A view to summarize the shells within a MultiShell
    // ---------------------------------------------------------------------

    PlaylistView: ShellView.extend({

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

        var currentIndex = this.options.parent.currentViewIndex();

        var summaries = this.$el.find('#summaries');
        _.map(this.options.parent.shells, function(shell, idx) {

          var summary = new shell.SummaryView({
            shell: shell,
            parent: this,
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
        this.options.parent.showView(index);
        this.remove();
      },

    }),

    EditView: Shell.prototype.EditView.extend({

      // **shellViews** is a container for sub shellViews.
      shellViews: [],

      events: {
        'click button#add': 'onClickAdd',
      },

      template: _.template('\
        <div id="subshells"></div>\
        <button class="btn btn-success btn-large" id="add">Add Link</button>\
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
        var shellView = new shell.EditView({
          shell: shell,
          parent: this,
        });

        // listen to events of shell EditView
        shellView.on('swap:shell', function(data) {
          this.onSwapSubShell(data, index);
        }, this);

        shellView.on('change:shell', function(data) {
          this.onChangeSubShell(data, index);
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

      // **onEdit** overridden to fwd to the first shellView
      onEdit: function() {
        if (this.shellViews.length > 0)
          this.shellViews[0].onEdit();
      },

      // **onSave** overridden to fwd to all shellViews.
      onSave: function() {
        if (!this.shouldSave())
          return; // bail out if we shouldn't save

        this.map(function (shellView) { shellView.onSave(); });
      },

      // **onChangeShell** overriden to prevent re-render
      onChangeShell: function() {},



      // -- MultiShell Events

      onChangeEditState: function() {
        this.trigger('change:editState');
      },

      // **onClickAdd** add another link + shell
      onClickAdd: function() {
        // // additional, placeholder adding shells
        var nextIndex = this.shellViews.length;
        var addData = acorn.shellForLink('').data;
        var addView = this.constructView(addData, nextIndex);

        addView.render();
        this.shellViews.push(addView);

        var subshells_el = this.$el.find('#subshells');
        subshells_el.append(addView.el);
      },

      // -- Sub Shell Events

      onSwapSubShell: function(data, index) {
        var oldShellView = this.shellViews[index];
        var newShellView = this.constructView(data);

        // render and add the new shellView.
        newShellView.render();
        oldShellView.$el.after(newShellView.el);

        // remvoe old shellView
        oldShellView.remove();
        this.shellViews[index] = newShellView;

        // update the data itself
        var shells = this.shells();
        shells[index] = data;
        this.shells(shells);
      },

      onChangeSubShell: function(shell, index) {
        // update the data itself
        var shells = this.shells();
        shells[index] = shell.data;
        this.shells(shells);
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

      // helper to map `func` through `shellViews` with `this` as context
      map: function(func) {
        return _.map(this.shellViews, func, this);
      },

    }),

  });


  // Add each shell to the registry under its shellid.
  _.each(acorn.shells, function(shell) {
    acorn.shells[shell.prototype.shellid] = shell;
  });

}).call(this);
