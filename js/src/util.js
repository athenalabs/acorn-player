(function() {

var root = this;
var util = root.util = (root.util || {});

// util
// ----------

// Utility functions.

// **assert** throw error if ``condition`` does not evaluate to true.
var assert = function(condition, description) {
  if (!condition)
    AssertionFailed(description);
};
util.assert = assert;

// **urlRegExp** Helper to contruct URL RegExps
var urlRegExp = function(simpleUrl) {
  return RegExp(
    '^'
      + '(https?:\/\/)?'
      + simpleUrl
  // + ((simpleUrl.search(/\?/) === -1) ?  '\?.*' : '')
    + '$'
  , 'i');
};
util.urlRegExp = urlRegExp;

// **derives** Helper to check the inheritance chain.
var derives = function(child, parent) {

  if (!child.__super__)
    return false;

  if (parent.prototype === child.__super__)
    return true;

  return derives(child.__super__.constructor, parent);
};
util.derives = derives;


// **code** escape html values for code blocks.
var code = function(code) {
  return escape(code);
};
util.code = code;


// **util.url** returns a url pointing to given path in acorn website.
util.url = function() {
  var path = Array.prototype.slice.call(arguments);
  var url = 'http://' + config.domain;
  if (path.length > 0)
    url += '/' + path.join('/');

  return url;
};

// **util.apiurl** returns an acorn api url
util.apiurl = function() {
  var path = Array.prototype.slice.call(arguments);
  var apiurl = util.url() + '/api/v' + config.APIVERSION;
  if (path.length > 0)
    apiurl += '/' + path.join('/');

  return apiurl;
};

// **util.imgurl** returns a URL to static images
// derived from `arguments`
util.imgurl = function() {
  var args = Array.prototype.slice.call(arguments);
  var urlargs = ['img'].concat(args);
  return util.url.apply(this, urlargs);
};

util.embed_iframe = function(src, id) {
  var f = $('<iframe>');
  f.attr('frameborder', '0').attr('border', '0');
  f.attr('width', '600').attr('height', '400');
  f.attr('allowFullScreen', 'true')
   .attr('webkitAllowFullScreen', 'true')
   .attr('mozallowfullscreen', 'true');
  f.attr('src', src);
  f.attr('scrolling', 'no');
  if (id)
    f.attr('id', id)
  return f;
};

// **alert_el** returns a bootstrap alert element
// Args:
// * msg - message to be displayed in the alert
// * type (default: alert-info) - type of alert-{error,info,success}
util.alert_el = function(msg, type) {
  type = typeof type !== 'undefined' ? type : 'alert-info';

  var alert_el =
    $('<div>').addClass('alert').addClass(type).text(msg);

  var button =
    $('<button>').addClass('close')
                 .attr('data-dismiss', 'alert')
                 .attr('href', '#').text('x');
  alert_el.append(button);

  return alert_el;
};

// **alert** creates and appends a bootstrap alert onto $('body')
// Args:
// * msg - message to be displayed in the alert
// * type (default: alert-info) - type of alert-{error,info,success}
alert = function(msg, type) {
  var alert_el = util.alert_el(msg, type);
  $('body').append(alert_el);
};
util.alert = alert; // util alias


// **iframe** creates and return an <iframe> element with options
// Args:
// * src - the source of the iframe
// * id (optional) - the id to assign to the frame
var iframe = function(src, id) {
  var f = $('<iframe>');
  f.attr('frameborder', '0').attr('border', '0');
  f.attr('allowTransparency', 'true');
  f.attr('allowFullScreen', 'true')
   .attr('webkitAllowFullScreen', 'true')
   .attr('mozallowfullscreen', 'true');
  f.attr('src', src);
  if (id)
    f.attr('id', id)
  return f;
};
util.iframe = iframe;

// **acornInFrame** get the acorn variable in <iframe> element
// Args:
// * iframe - the iframe element
util.acornInFrame = function(iframe) {
  // if iframe is a jquery selector, get the first element.
  if (iframe.jquery)
    iframe = iframe.get(0);

  // get the window within the iframe
  var f = iframe;
  var w = f.contentWindow ? f.contentWindow : f.contentDocument.defaultView;

  return w.acorn; // if acorn is undefined, it doesn't exist yet.
};


// **property** creates and return a get/setter with a closured var.
var property = function(defaultValue, validate) {

  // initialize with defaultValue
  var storedValue = defaultValue;

  // ensure we have at least an empty validate function
  if (typeof(validate) !== 'function') {
    validate = function(v) { return v; };
  };

  // return the get/setter function; validate should raise error if invalid
  return function(value) {
    if (arguments.length > 0) {
      storedValue = validate(value);
    };

    return storedValue;
  };
};
util.property = property;

// **timeStringToSeconds** converts human-readable timeString to seconds
// human-readable format is: [[hh:]mm:]ss[.SSS]
var timeStringToSeconds = function(timeString) {
  if (!timeString)
    return 0;

  var parts = timeString.split('.');
  var subsec = parseFloat('0.' + (parts.length > 1 ? parts[1] : '0'));

  parts = (parts[0] || '0').split(':');
  var sec = parseInt(parts.pop(), 10);
  var min = (parts.length > 0) ? parseInt(parts.pop(), 10) : 0;
  var hrs = (parts.length > 0) ? parseInt(parts.pop(), 10) : 0;

  return (hrs * 60 * 60) + (min * 60) + sec + subsec;
};
util.timeStringToSeconds = timeStringToSeconds;

// **secondsToTimeString** converts seconds to human-readable timeString
// human-readable format is: [[hh:]mm:]ss[.SSS]
// format param may force placeholder zeroes in minutes or hours and minutes
var secondsToTimeString = function(seconds, format) {
  var timeString = '';

  _.isObject(format) || (format = {});

  // get integer seconds
  var sec = parseInt(seconds, 10);

  // add hours part
  var hrs = parseInt(sec / (60 * 60), 10);
  if (hrs !== 0 || format.forceHours) {
    sec -= hrs * 60 * 60;
    timeString += hrs + ':';
  };

  // add minutes part
  var min = parseInt(sec / 60, 10);
  if (hrs !== 0 || min !== 0 || format.forceHours || format.forceMinutes) {
    sec -= min * 60;
    min = (min < 10) ? '0' + min : min;
    timeString += min + ':';
  };

  // add seconds part
  sec = (sec < 10) ? '0' + sec : sec;
  timeString += sec;

  // add subsecond part
  var subsec = seconds % 1;
  if (subsec) {
    subsec = Math.round(subsec * 1000) / 1000;
    subsec = ('' + subsec).substr(1, 4); // remove first '0'
    subsec = subsec.replace(/0+$/, '');
    timeString += subsec;
  };

  return timeString;
};
util.secondsToTimeString = secondsToTimeString;

// **testTimeConversions** TODO: move to a test file.
// tests ``timeStringToSeconds`` and ``secondsToTimeString``
util.testTimeConversions = function() {

  function assertEquals(a, b) {
    var str = 'assertEquals(' + a + ', ' + b + ')';
    if (a === b) {
      console.log(str + ' PASSED');
    } else {
      console.log(str + ' FAILED');
      assert(a === b, a + ' != ' + b);
    };
  };

  assertEquals(timeStringToSeconds('0'), 0);
  assertEquals(timeStringToSeconds('1'), 1);
  assertEquals(timeStringToSeconds('10'), 10);
  assertEquals(timeStringToSeconds('50'), 50);
  assertEquals(timeStringToSeconds('60'), 60);
  assertEquals(timeStringToSeconds('.1'), 0.1);
  assertEquals(timeStringToSeconds('1.1'), 1.1);
  assertEquals(timeStringToSeconds('.11'), 0.11);
  assertEquals(timeStringToSeconds('.111'), 0.111);
  assertEquals(timeStringToSeconds('9.999'), 9.999);
  assertEquals(timeStringToSeconds('1:00'), 60);
  assertEquals(timeStringToSeconds('1:10'), 70);
  assertEquals(timeStringToSeconds('1:60'), 120);
  assertEquals(timeStringToSeconds('10:00'), 600);
  assertEquals(timeStringToSeconds('10:10'), 610);
  assertEquals(timeStringToSeconds('11:11'), 671);
  assertEquals(timeStringToSeconds('1:00:00'), 3600);
  assertEquals(timeStringToSeconds('10:00:00'), 36000);
  assertEquals(timeStringToSeconds('111:11:11'), 400271);
  assertEquals(timeStringToSeconds('111:11:11.111'), 400271.111);
  assertEquals(timeStringToSeconds('123:45:67.890'), 445567.89);


  assertEquals(secondsToTimeString(0), '00');
  assertEquals(secondsToTimeString(1), '01');
  assertEquals(secondsToTimeString(10), '10');
  assertEquals(secondsToTimeString(50), '50');
  assertEquals(secondsToTimeString(60), '01:00');
  assertEquals(secondsToTimeString(0.1), '00.1');
  assertEquals(secondsToTimeString(1.1), '01.1');
  assertEquals(secondsToTimeString(0.11), '00.11');
  assertEquals(secondsToTimeString(0.111), '00.111');
  assertEquals(secondsToTimeString(9.999), '09.999');
  assertEquals(secondsToTimeString(60), '01:00');
  assertEquals(secondsToTimeString(70), '01:10');
  assertEquals(secondsToTimeString(120), '02:00');
  assertEquals(secondsToTimeString(600), '10:00');
  assertEquals(secondsToTimeString(610), '10:10');
  assertEquals(secondsToTimeString(671), '11:11');
  assertEquals(secondsToTimeString(3600), '1:00:00');
  assertEquals(secondsToTimeString(36000), '10:00:00');
  assertEquals(secondsToTimeString(400271), '111:11:11');
  assertEquals(secondsToTimeString(400271.111), '111:11:11.111');
  assertEquals(secondsToTimeString(445567.89), '123:46:07.89');
};



// The following functions are originally from other open-source projects.
// They are replicated here to avoid dependencies for minimal things.

// Originally from underscore.js 1.3.1:

var isArray = function (arr) {
  return Object.prototype.toString.call(arr) === '[object Array]';
};

var isObject = function(obj) {
  return obj === Object(obj);
};

var isFunction = function(fxn) {
  return Object.prototype.toString.call(fxn) === '[object Function]';
};

// Extend a given object with all the properties in passed-in object(s).
var extend = function(obj) {
  for (var arg in arguments) {
    var source = arguments[arg]
    if (source === obj)
      continue;

    for (var prop in source) {
      obj[prop] = source[prop];
    };
  };
  return obj;
};
util.extend = extend;

// Copy an object.
var clone = function(obj) {
  if (!isObject(obj)) return obj;
  return isArray(obj) ? obj.slice() : extend({}, obj);
};
util.clone = clone;



// Originally from backbone.js 0.9.1:

// Shared empty constructor function to aid in prototype-chain creation.
var ctor = function() {};

// Helper function to correctly set up the prototype chain, for subclasses.
// Similar to `goog.inherits`, but uses a hash of prototype properties and
// class properties to be extended.
var inherits = function(parent, protoProps, staticProps) {
  var child;

  // The constructor function for the new subclass is either defined by you
  // (the "constructor" property in your `extend` definition), or defaulted
  // by us to simply call the parent's constructor.
  if (protoProps && protoProps.hasOwnProperty('constructor')) {
    child = protoProps.constructor;
  } else {
    child = function() { parent.apply(this, arguments); };
  };

  // Inherit class (static) properties from parent.
  extend(child, parent);

  // Set the prototype chain to inherit from `parent`, without calling
  // `parent`'s constructor function.
  ctor.prototype = parent.prototype;
  child.prototype = new ctor();

  // Add prototype properties (instance properties) to the subclass,
  // if supplied.
  if (protoProps)
    extend(child.prototype, protoProps);

  // Add static properties to the constructor function, if supplied.
  if (staticProps)
    extend(child, staticProps);

  // Correctly set child's `prototype.constructor`.
  child.prototype.constructor = child;

  // Set a convenience property in case the parent is needed later.
  child.__super__ = parent.prototype;

  // Add the derives property.
  child.derives = function(parent) { return derives(this, parent); };

  return child;
};
util.inherits = inherits;

// The self-propagating extend function that Backbone classes use.
var extendPrototype = function (protoProps, classProps) {
  var child = inherits(this, protoProps, classProps);
  child.extend = this.extend;
  return child;
};
util.extendPrototype = extendPrototype;

// Helper function to get a value from an object as a property or function.
var getValue = function(object, prop) {
  if (!(object && object[prop])) return null;
  return isFunction(object[prop]) ? object[prop]() : object[prop];
};
util.getValue = getValue;


// Originally from StackOverflow
// http://stackoverflow.com/questions/736513

var parseUrl = function(url) {

  var result = {};

  // trim out any whitespace
  url = $.trim(url);

  // if no protocol is found, prepend http
  if (!RegExp('://').test(url))
    url = 'http://' + url;

  var anchor = document.createElement('a');
  anchor.href = url;

  var k = 'protocol hostname host pathname port search hash href'.split(' ');
  for (var keyIdx in k) {
    var key = k[keyIdx];
    result[key] = anchor[key];
  };

  result.toString = function() { return result.href; };
  result.resource = result.pathname + result.search;
  result.extension = result.pathname.split('.').pop();

  result.head = function() {
    NotSupportedError('head', 'Yet.');
  };

  for (var prop in result) {
    if (prop[prop.length -1] === '_')
      continue;

    if (typeof result[prop] === 'string')
      result[prop + '_'] = result[prop].toLowerCase();
  };

  return result;
};
util.parseUrl = parseUrl;


}).call(this);
