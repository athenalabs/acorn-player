
// VideoPlaybackInterface -- defines methods all video shells must support.
// ------------------------------------------------------------------------


var VideoPlaybackInterface = {

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

};


// Timer -- an object to execute periodic callbacks.
// -------------------------------------------------

var Timer = function(interval, callback, args) {
  _.bindAll(this);
  this.interval = interval;
  this.callback = callback || function() {};
  this.args = args || [];
};

_.extend(Timer.prototype, {

  // start the interval
  startTick: function() {
    this.stopTick();
    this.intervalObject = setInterval(this.onTick, this.interval);
  },

  // clear the interval
  stopTick: function() {
    if (this.intervalObject) {
      clearInterval(this.intervalObject);
      this.intervalObject = undefined;
    }
  },

  // tick callback
  onTick: function() {
    this.callback.call(this, this.args);
  },

});


// VideoLinkShell -- a shell that links to video and embeds it.
// ------------------------------------------------------------

var VideoLinkShell = acorn.shells.VideoLinkShell = LinkShell.extend({

  shellid: 'acorn.VideoLinkShell',

  // The canonical type of this media. One of `acorn.types`.
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

});


// Shell.ContentView -- displays the video within the bounds of the player.
// ------------------------------------------------------------------------

VideoLinkShell.ContentView = LinkShell.ContentView.extend({

  initialize: function() {
    LinkShell.ContentView.prototype.initialize.call(this);

    this.timer = new Timer(200, this.onPlaybackTick);
  },

  render: function() {
    this.$el.empty();

    // stop ticking, in case we had been playing and this is a re-render.
    this.timer.stopTick();
  },

  remove: function() {
    this.timer.stopTick(); // stop the interval on remove.

    LinkShell.ContentView.prototype.remove.call(this);
  },


  // shell.ContentView events
  // ------------------------

  onPlaybackStop: function() {
    this.stop();
  },

  onPlaybackPlay: function() {
    this.play();
  },


  // onPlaybackTick -- executes periodically to adjust video playback.
  // -----------------------------------------------------------------

  onPlaybackTick: function() {
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
        this.trigger('playback:ended');
      }
    }
  },

});


// VideoLinkShell.EditView -- video link, time clipping, and other options.
// ------------------------------------------------------------------------

VideoLinkShell.EditView = LinkShell.EditView.extend({

  events: _.extend({}, LinkShell.EditView.prototype.events, {
    'change input':  'timeInputChanged',
    'blur input':  'timeInputChanged',
  }),

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
    total time: <span id="time"></span>\
    <label class="checkbox right" id="loop-label">\
      <input id="loop" type="checkbox"> Loop\
    </label>\
  </form>\
  '),

  render: function() {
    LinkShell.EditView.prototype.render.call(this);

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
      slide: function(e, ui) {
        self.inputChanged(ui.values);
      },
      stop: function(e, ui) {
        self.trigger('change:shell', self.shell);
      },
    });

    this.inputChanged([ data.time_start, data.time_end ]);

  },

  timeInputChanged: function() {
    this.inputChanged([
      timeStringToSeconds(this.$el.find('#start').val()),
      timeStringToSeconds(this.$el.find('#end').val())
    ]);
    this.trigger('change:shell', this.shell);
  },

  inputChanged: function(values) {
    var clip = function(min, val, max) {
      return Math.max(min, Math.min(val || 0, max));
    };

    var floatOrDefault = function(num, def) {
      return (_.isNumber(num) && !_.isNaN(num)) ? parseFloat(num) : def;
    };

    var max = this.shell.data.time_total || this.shell.duration();
    values[0] = floatOrDefault(values[0], 0);
    values[1] = floatOrDefault(values[1], max);

    var start = clip(0, values[0], values[1]);
    var end = clip(start, values[1], max);
    var loop = !!this.$el.find('#loop').attr('checked');

    var diff = (end - start);
    var time = (isNaN(diff) ? '--' : secondsToTimeString(diff));

    this.shell.data.time_start = start;
    this.shell.data.time_end = end;
    this.shell.data.loop = loop;

    this.$el.find('#start').val(secondsToTimeString(start));
    this.$el.find('#end').val(secondsToTimeString(end));
    this.$el.find('#time').text(time);
    this.$el.find('#slider').slider({ max: max, values: [start, end] });
  },

});


// Register the shell with the acorn object.
acorn.registerShell(VideoLinkShell);
