// acorn.shells.VimeoShell -- links to vimeo video and embeds it.
// --------------------------------------------------------------

var VimeoShell = acorn.shells.VimeoShell = VideoLinkShell.extend({

  shellid: 'acorn.VimeoShell',

  // The canonical type of this media. One of `acorn.types`.
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

  metaDataLink: function() {
    return 'http://vimeo.com/api/v2/video/' + this.vimeoId() + '.json?'
         + '&callback=?' // somehow allows cross-domain requests.
         ;
  },

  // **title** returns a simple title of the shell
  title: function() {
    return this.metaData() ? this.metaData()[0].title : this.link();
  },

  // **description** returns a simple description of the shell
  description: function() {
    return 'Seconds ' + (this.data.time_start || 0)
         + ' to ' + (this.data.time_end || this.duration())
         + ' of Vimeo video '
         + this.link();
  },

  duration: function() {
    return this.metaData() ? this.metaData()[0].duration : this.data.time_end;
  },


  // **validRegexes** list of valid LinkRegexes
  validRegexes: [
    urlRegExp('(www\.)?(player\.)?vimeo\.com\/(video\/)?([0-9]+).*'),
  ],

});


// ContentView -- displays the embedded player, and interacts through js api.
// --------------------------------------------------------------------------

VimeoShell.ContentView = VideoLinkShell.ContentView.extend({

  render: function() {
    this.$el.empty();

    // stop ticking, in case we had been playing and this is a re-render.
    this.timer.stopTick();

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
    this.timer.onTick();
  },

  // override {start,stop}Tick, as Vimeo has it's own interval callback.
  startTick: function() {},
  stopTick: function() {},

  // VideoLinkShell.ContentView interface -- overriding with native impl.
  // --------------------------------------------------------------------

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

});


// EditView -- video link, time clipping, and other options.
// ---------------------------------------------------------

VimeoShell.EditView = VideoLinkShell.EditView.extend({
  // Overrides LinkShell.generateThumbnailLink()
  generateThumbnailLink: function(callback) {
    // TODO(ali01) use retrieveMetaData?

    // This would be the code. It works, and it leverages the fact
    // that ``retrieveMetaData`` already has to be called for the
    // duration. I think if we fix things away from $.getJSON we'd
    // do it in retrieveMetaData, so I think this below should be
    // what actually generates the thumbnail.

    // this.shell.retrieveMetaData(_.bind(function() {
    //   callback(this.shell.metaData[0].thumbnail_large);
    // }, this));

    callback = callback || function() {};
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
});


// Register the shell with the acorn object.
acorn.registerShell(VimeoShell);
