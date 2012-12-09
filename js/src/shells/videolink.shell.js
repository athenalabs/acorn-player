(function() {

var LinkShell = acorn.shells.LinkShell;
var secondsToTimeString = acorn.util.secondsToTimeString;

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
    acorn.util.urlRegExp('.*\.(avi|mov|wmv)'),
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
    var loops = this.shell.data.loops;
    var end = this.shell.data.time_end || this.totalTime();
    var start = this.shell.data.time_start || 0;

    // get current state
    var now = this.currentTime();
    var playing = this.isPlaying();

    // if current playback is behind the start time, seek to start
    if (playing && now < start) {
      this.seek(start);
    }

    // if current playback is after the end time, pause or loop. when looping,
    // set `restarting` flag to avoid decrementing the loop count multiple
    // times before the restart has completed
    if (playing && now >= end) {
      if (this.restarting)
        return;

      if (_.isNumber(loops)) {
        this.looped = this.looped || 0;
        this.looped++;
      };

      if (loops === 'infinity' || (_.isNumber(loops) && loops > this.looped)) {
        this.seek(start);
        this.restarting = true;

      } else {
        this.stop();
        this.trigger('playback:ended');
      };

    } else {
      this.restarting = false;
    };
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
    'click button.loops': 'onClickLoopsButton',
    'change input.n-loops': 'onChangeNLoops',
    'blur input.n-loops': 'onChangeNLoops',
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
    <div class="input-prepend input-append loops one-loops">\
      <button class="btn loops" type="button">loops:</button>\
      <span class="add-on one-loops">1</span>\
    </div>\
    <div class="input-prepend input-append loops infinity-loops">\
      <button class="btn loops" type="button">loops:</button>\
      <span class="add-on infinity-loops">∞</span>\
    </div>\
    <div class="input-prepend loops n-loops">\
      <button class="btn loops" type="button">loops:</button>\
      <input size="16" type="text" class="n-loops">\
    </div>\
  </form>\
  '),

  render: function() {
    LinkShell.EditView.prototype.render.call(this);

    var timeRange = $(this.timeRangeTemplate());

    this.$el.find('.thumbnailside').append(timeRange);
    this.$el.find('#slider').css('opacity', '0.0');
    this.setupSlider();
    this.setupLoopsButton();

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

  setupLoopsButton: function() {
    switch(this.shell.data.loops) {
      case 'one':
        this.showLoops('one');
        break;

      case 'infinity':
        this.showLoops('infinity');
        break;

      default:
        // set nLoops value internally and in DOM before showing loop widget
        this.nLoops(this.shell.data.loops);
        this.$('input.n-loops').val(this.nLoops());
        this.showLoops('n');
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

  nLoops: function(n) {
    // force integer or NaN - don't interpret whitespace as 0
    var int = Math.floor(n);
    if (int === 0 && n !== 0)
      int = NaN;

    if (int >= 0)
      this._lastNLoops = int;
    else if (!_.isNumber(this._lastNLoops))
      this._lastNLoops = 2;

    return this._lastNLoops;
  },

  showLoops: function(type) {
    var active = this.$('div.' + type + '-loops');

    this.$('div.loops').addClass('hidden');
    active.removeClass('hidden');

    if (this._selectInputOnShow) {
      active.find('input').select();
      this._selectInputOnShow = false;
    };
  },

  onClickLoopsButton: function() {
    switch (this.shell.data.loops) {
      case 'one':
        this.shell.data.loops = 'infinity';
        break;

      case 'infinity':
        this.shell.data.loops = this.nLoops();
        this._selectInputOnShow = true;
        break;

      default:
        this.shell.data.loops = 'one';
    };

    this.trigger('change:shell', this.shell, this);
  },

  onChangeNLoops: function() {
    var value, newNLoops;

    value = this.$('input.n-loops').val();
    newNLoops = this.nLoops(value);
    this.$('input.n-loops').val(newNLoops);

    if (this.shell.data.loops !== newNLoops) {
      this.shell.data.loops = newNLoops;
      this.trigger('change:shell', this.shell, this);
    };
  },

});


// Register the shell with the acorn object.
acorn.registerShell(VideoLinkShell);

}).call(this);
