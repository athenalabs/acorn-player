
// acorn.shells.YouTubeShell -- links to youtube video and embeds it.
// ------------------------------------------------------------------

var YouTubeShell = acorn.shells.YouTubeShell = VideoLinkShell.extend({

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

  // **validRegexes** list of valid LinkRegexes
  validRegexes: [
    UrlRegExp('(www\.)?youtube\.com\/v\/([A-Za-z0-9\-_]+).*'),
    UrlRegExp('(www\.)?youtube\.com\/embed\/([A-Za-z0-9\-_]+).*'),
    UrlRegExp('(www\.)?youtube\.com\/watch\?.*v=([A-Za-z0-9\-_]+).*'),
    UrlRegExp('(www\.)?y2u.be\/([A-Za-z0-9\-_]+)'),
  ],

});



// ContentView -- displays the embedded player, and interacts through js api.
// --------------------------------------------------------------------------

YouTubeShell.ContentView = VideoLinkShell.ContentView.extend({

  render: function() {
    VideoLinkShell.ContentView.prototype.render.call(this);

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
      this.timer.startTick();
    else
      this.timer.stopTick();
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

});


// EditView -- video link, time clipping, and other options.
// ---------------------------------------------------------

YouTubeShell.EditView = VideoLinkShell.EditView.extend({
  // Overrides LinkShell.generateThumbnailLink()
  generateThumbnailLink: function(callback) {
    callback(this.shell.thumbnailLink());
  },
});


// Register the shell with the acorn object.
acorn.registerShell(YouTubeShell);
