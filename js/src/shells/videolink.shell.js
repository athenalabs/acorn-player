
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
    urlRegExp('.*\.(avi|mov|wmv)'),
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
    // TODO: handle looping correctly
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
    'change input#start':  'startTimeInputChanged',
    'blur input#start':  'startTimeInputChanged',
    'change input#end':  'endTimeInputChanged',
    'blur input#end':  'endTimeInputChanged',
    'click button.loop': 'onClickLoopButton',
    'change input.loop-n': 'onChangeLoopN',
    'blur input.loop-n': 'onChangeLoopN',
  }),

  timeRangeTemplate: _.template('\
  <div id="slider-block">\
    <div id="slider" class="fader"></div>\
    <div id="time"></div>\
  </div>\
  <form class="form-inline">\
    <div class="control-group time">\
      <div class="input-prepend">\
        <span class="add-on">start:</span>\
        <input id="start" size="16" type="text" class="time">\
        <!--<span class="add-on">sec</span>-->\
      </div>\
    </div>\
    <div class="control-group time">\
      <div class="input-prepend">\
        <span class="add-on">end:</span>\
        <input id="end" size="16" type="text" class="time">\
        <!--<span class="add-on">sec</span>-->\
      </div>\
    </div>\
    <div class="input-prepend input-append loop loop-none">\
      <button class="btn loop" type="button">loop:</button>\
      <span class="add-on loop-none">∅</span>\
    </div>\
    <div class="input-prepend input-append loop loop-infinity">\
      <button class="btn loop" type="button">loop:</button>\
      <span class="add-on loop-infinity">∞</span>\
    </div>\
    <div class="input-prepend loop loop-n">\
      <button class="btn loop" type="button">loop:</button>\
      <input size="16" type="text" class="loop-n">\
    </div>\
  </form>\
  '),

  render: function() {
    LinkShell.EditView.prototype.render.call(this);

    var timeRange = $(this.timeRangeTemplate());

    this.$el.find('.thumbnailside').append(timeRange);
    this.$el.find('#slider').css('opacity', '0.0');
    this.setupSlider();
    this.setupLoopButton();

    var metaDataCache = this.shell.metaData();
    metaDataCache.sync({
      success: _.bind(function() {
        this.setupSlider();
        this.$el.find('#slider').css('opacity', '1.0');
      }, this),
    });
  },

  setupSlider: function() {
    var data, max, self, start, end;

    data = this.shell.data;
    max = this.shell.duration();

    // setup slider
    self = this;
    this.$el.find('#slider').rangeslider({
      min: 0,
      max: max,
      range: true,
      values: [ data.time_start || 0, data.time_end || max],
      slide: function(e, ui) {
        start = ui.values[0];
        end = ui.values[1];
        self.inputChanged({start: start, end: end});
      },
      stop: function(e, ui) {
        self.trigger('change:shell', self.shell, self);
      },
    });

    this.inputChanged({start: data.time_start, end: data.time_end});
  },

  setupLoopButton: function() {
    switch(this.shell.data.loop) {
      case 'none':
        this.showLoop('none');
        break;

      case 'infinity':
        this.showLoop('infinity');
        break;

      default:
        // set internal loopN value and add it to DOM before showing loop widget
        this.loopN(this.shell.data.loop);
        this.$('input.loop-n').val(this.loopN());
        this.showLoop('n');
    };
  },

  startTimeInputChanged: function() {
    this.timeInputChanged('start');
  },

  endTimeInputChanged: function() {
    this.timeInputChanged('end');
  },

  timeInputChanged: function(changed) {
    var data = {
      start: timeStringToSeconds(this.$el.find('#start').val()),
      end: timeStringToSeconds(this.$el.find('#end').val()),
    };

    this.inputChanged(data, {lock: changed, updateSlider: true});

    this.trigger('change:shell', this.shell, this);
  },

  // Args, contained in a single object:
  // @number start - current start time in seconds
  // @number end - current end time in seconds
  // @string [lock] - name the time nob ('start' or 'end') to lock down if the
  //     times are incompatible (e.g. start = 46, end = 19). by default, start
  //     will be locked
  inputChanged: function(data, options) {
    var offset, max, bound, floatOrDefault, start, end, invalidTimes, diff,
        time;

    _.isObject(options) || (options = {});
    offset = 10;
    max = this.shell.data.time_total || this.shell.duration();

    bound = function(val) {
      return Math.max(0, Math.min(val || 0, max));
    };

    floatOrDefault = function(num, def) {
      return (_.isNumber(num) && !_.isNaN(num)) ? parseFloat(num) : def;
    };

    start = floatOrDefault(data.start, 0);
    end = floatOrDefault(data.end, max);

    start = bound(start);
    end = bound(end);

    // prohibit negative length
    invalidTimes = end < start;

    if (invalidTimes) {
      if (options.lock === 'end')
        start = bound(end - offset);
      else
        end = bound(start + offset);

      // after rerender(s), display time error
      setTimeout(this.timeError, 0);
    };

    diff = (end - start);
    time = (isNaN(diff) ? '--' : secondsToTimeString(diff,
        {forceMinutes: true}));

    this.shell.data.time_start = start;
    this.shell.data.time_end = end;

    this.$el.find('#start').val(secondsToTimeString(start,
        {forceMinutes: true}));
    this.$el.find('#end').val(secondsToTimeString(end, {forceMinutes: true}));
    this.$el.find('#time').text(time);

    if (options.updateSlider || invalidTimes)
      this.$el.find('#slider').rangeslider({values: [start, end]});
  },

  timeError: function() {
    // 2 seconds of error display
    var timeControls = this.$('form').children('.control-group.time');
    timeControls.addClass('error');
    setTimeout(function() { timeControls.removeClass('error'); }, 2000);
  },

  loopN: function(n) {
    // force integer or NaN - don't interpret whitespace as 0
    var int = Math.floor(n);
    if (int === 0 && n !== 0)
      int = NaN;

    if (int >= 0)
      this._lastLoopN = int;
    else if (!_.isNumber(this._lastLoopN))
      this._lastLoopN = 2;

    return this._lastLoopN;
  },

  showLoop: function(type) {
    var active = this.$('div.loop-' + type);

    this.$('div.loop').addClass('hidden');
    active.removeClass('hidden');

    if (this._selectInputOnShow) {
      active.find('input').select();
      this._selectInputOnShow = false;
    };
  },

  onClickLoopButton: function() {
    switch (this.shell.data.loop) {
      case 'none':
        this.shell.data.loop = 'infinity';
        break;

      case 'infinity':
        this.shell.data.loop = this.loopN();
        this._selectInputOnShow = true;
        break;

      default:
        this.shell.data.loop = 'none';
    };

    this.trigger('change:shell', this.shell, this);
  },

  onChangeLoopN: function() {
    var value, newLoopN;

    value = this.$('input.loop-n').val();
    newLoopN = this.loopN(value);
    this.$('input.loop-n').val(newLoopN);

    if (this.shell.data.loop !== newLoopN) {
      this.shell.data.loop = newLoopN;
      this.trigger('change:shell', this.shell, this);
    };
  },

});


// Register the shell with the acorn object.
acorn.registerShell(VideoLinkShell);
