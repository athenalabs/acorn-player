//     acorn.js 0.0.0
//     (c) 2012 Juan Batiz-Benet, Athena.
//     Acorn is freely distributable under the MIT license.
//     Inspired by github:gist.
//     Portions of code from Underscore.js and Backbone.js
//     For all details and documentation:
//     http://github.com/athenalabs/acorn-player

(function() {

  // Setup
  // -----

  // Establish the root object, `window` in browser, or `global` on server.
  var root = this;

  // For acorn's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  var $ = root.jQuery || root.Zepto || root.ender;

  // Save the previous value of the `_` variable.
  var previousAcorn = root.acorn;

  // The top-level namespace. All public acorn classes and modules will
  // be attached to this. Exported for both CommonJS and the browser.
  var acorn;
  if (typeof exports !== 'undefined') {
    acorn = exports;
  } else {
    acorn = root.acorn = function(acornid) {
      acornid = acornid || 'new';
      acornid = acornid.trim().split('/').pop();
      return new acorn.Model({'acornid': acornid});
    };
  }

  // Current version.
  acorn.VERSION = '0.0.0';

  // API Version
  acorn.APIVERSION = '0.0.1';

  // Acorn service domain
  acorn.domain = 'staging.acorn.athena.ai';

  // Acorn Url
  // For now, use whatever host we're running on
  acorn.url = 'http://' + window.location.host;

  // Acorn API Url
  acorn.apiurl = 'http://' + acorn.domain + '/api/v' + acorn.APIVERSION;

  // Initialize collections
  acorn.options = {};
  acorn.errors = {};
  acorn.types = {};
  acorn.util = {};

  // Errors
  // ------

  var NotImplementedError = function(method) {
    throw new Error(method + ' not implemented. Did you override it?');
  };

  var NotSupportedError = function(method, extra) {
    throw new Error(method + ' not supported. ' +  (extra || '') );
  };

  var ParameterError = function(param) {
    throw new Error('Parameter error: ' + param + ' must be specified.');
  };

  var GetKeyOrSetObjError = function() {
    ParameterError('key to retrieve or object with new key-value pairs to set');
  };

  var UrlError = function() {
    ParameterError('"url" property or function');
  };

  var UndefinedShellError = function(shell) {
    throw new Error('Attempt to construct undefined shell ' + shell);
  };

  var APIError = function(description) {
    throw new Error('Acorn API Error: ' + description);
  };

  var AssertionFailed = function(description) {
    throw new Error('Assertion failed: ' + description);
  };

  acorn.errors.UrlError = UrlError;
  acorn.errors.APIError = APIError;
  acorn.errors.ParameterError = ParameterError;
  acorn.errors.NotSupportedError = NotSupportedError;
  acorn.errors.GetKeyOrSetObjError = GetKeyOrSetObjError;
  acorn.errors.UndefinedShellError = UndefinedShellError;
  acorn.errors.NotImplementedError = NotImplementedError;
  acorn.errors.AssertionFailed = AssertionFailed;

  // acorn.types
  // -----------

  // Cannonical types of media

  acorn.types.text = true;
  acorn.types.image = true;
  acorn.types.video = true;
  acorn.types.audio = true;
  acorn.types.document = true;
  acorn.types.link = true;
  acorn.types.interactive = true;
  acorn.types.multimedia = true; // group of other types.


  // acorn.util
  // ----------

  // Utility functions.

  // **assert** throw error if ``condition`` does not evaluate to true.
  var assert = function(condition, description) {
    if (!condition)
      AssertionFailed(description);
  };
  acorn.util.assert = assert;

  // **UrlRegExp** Helper to contruct URL RegExps
  var UrlRegExp = function(simpleUrl) {
    return RegExp(
      '^'
        + '(https?:\/\/)?'
        + simpleUrl
    // + ((simpleUrl.search(/\?/) === -1) ?  '\?.*' : '')
      + '$'
    , 'i');
  };
  acorn.util.UrlRegExp = UrlRegExp;

  // **derives** Helper to check the inheritance chain.
  var derives = function(child, parent) {

    if (!child.__super__)
      return false;

    if (parent.prototype === child.__super__)
      return true;

    return derives(child.__super__.constructor, parent);
  }
  acorn.util.derives = derives;


  // **code** escape html values for code blocks.
  var code = function(code) {
    return escape(code);
  };
  acorn.util.code = code;


  // **acorn.util.url** returns a url pointing to given path in acorn website.
  acorn.util.url = function() {
    var path = Array.prototype.slice.call(arguments);
    return acorn.url +'/'+ path.join('/');
  };

  // **acorn.util.apiurl** returns an acorn api url
  acorn.util.apiurl = function() {
    var path = Array.prototype.slice.call(arguments);
    return acorn.apiurl +'/'+ path.join('/');
  };

  acorn.util.imgurl = function() {
    var args = Array.prototype.slice.call(arguments);
    var urlargs = ['img'].concat(args);
    return acorn.util.url.apply(this, urlargs);
  };

  acorn.util.embed_iframe = function(src, id) {
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

  // **acorn.alert_el** returns a bootstrap alert element
  // Args:
  // * msg - message to be displayed in the alert
  // * type (default: alert-info) - type of alert-{error,info,success}
  acorn.util.alert_el = function(msg, type) {
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

  // **acorn.alert** creates and appends a bootstrap alert onto $('body')
  // Args:
  // * msg - message to be displayed in the alert
  // * type (default: alert-info) - type of alert-{error,info,success}
  acorn.alert = function(msg, type) {
    var alert_el = acorn.util.alert_el(msg, type);
    $('body').append(alert_el);
  };
  acorn.util.alert = acorn.alert; // util alias


  // **acorn.iframe** creates and return an <iframe> element with options
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
  acorn.util.iframe = iframe;

  // **acorn.acornInFrame** get the acorn variable in <iframe> element
  // Args:
  // * iframe - the iframe element
  acorn.util.acornInFrame = function(iframe) {
    // get the window within the iframe
    var f = playerFrame;
    var w = f.contentWindow ? f.contentWindow : f.contentDocument.defaultView;

    return w.acorn; // if acorn is undefined, it doesn't exist yet.
  };


  // **acorn.property** creates and return a get/setter with a closured var.
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
  acorn.util.property = property;

  // **acorn.timeStringToSeconds** converts human-readable timeString to seconds
  // human-readable format is: [[hh:]mm:]ss[.SSS]
  var timeStringToSeconds = function(timeString) {
    if (!timeString)
      return 0;

    var parts = timeString.split('.');
    var subsec = parseFloat('0.' + (parts.length > 1 ? parts[1] : '0'));

    parts = (parts[0] || '0').split(':');
    var sec = parseInt(parts.pop())
    var min = (parts.length > 0) ? parseInt(parts.pop()) : 0;
    var hrs = (parts.length > 0) ? parseInt(parts.pop()) : 0;


    return (hrs * 60 * 60) + (min * 60) + sec + subsec;
  };
  acorn.util.timeStringToSeconds = timeStringToSeconds;

  // **acorn.secondsToTimeString** converts seconds to human-readable timeString
  // human-readable format is: [[hh:]mm:]ss[.SSS]
  var secondsToTimeString = function(seconds) {
    var timeString = '';

    // get integer seconds
    var sec = parseInt(seconds);

    // add hours part
    var hrs = parseInt(sec / (60 * 60));
    if (hrs) {
      sec -= hrs * 60 * 60;
      timeString += hrs + ':';
    }

    // add minutes part
    var min = parseInt(sec / 60);
    if (hrs || min) {
      sec -= min * 60;
      min = (min < 10) ? '0' + min : min;
      timeString += min + ':';
    }

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
    }

    return timeString;
  };
  acorn.util.secondsToTimeString = secondsToTimeString;

  // **testTimeConversions** TODO: move to a test file.
  // tests ``timeStringToSeconds`` and ``secondsToTimeString``
  acorn.util.testTimeConversions = function() {

    function assertEquals(a, b) {
      var str = 'assertEquals(' + a + ', ' + b + ')';
      if (a == b) {
        console.log(str + ' PASSED');
      } else {
        console.log(str + ' FAILED');
        assert(a == b, a + ' != ' + b);
      }
    }

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
      }
    }
    return obj;
  };
  acorn.util.extend = extend;

  // Copy an object.
  var clone = function(obj) {
    if (!isObject(obj)) return obj;
    return isArray(obj) ? obj.slice() : extend({}, obj);
  };
  acorn.util.clone;


  // Originally from backbone.js 0.9.1:

  // Shared empty constructor function to aid in prototype-chain creation.
  var ctor = function(){};

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
    }

    // Inherit class (static) properties from parent.
    extend(child, parent);

    // Set the prototype chain to inherit from `parent`, without calling
    // `parent`'s constructor function.
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();

    // Add prototype properties (instance properties) to the subclass,
    // if supplied.
    if (protoProps) extend(child.prototype, protoProps);

    // Add static properties to the constructor function, if supplied.
    if (staticProps) extend(child, staticProps);

    // Correctly set child's `prototype.constructor`.
    child.prototype.constructor = child;

    // Set a convenience property in case the parent is needed later.
    child.__super__ = parent.prototype;

    // Add the derives property.
    child.derives = function(parent) { return derives(this, parent); };

    return child;
  };
  acorn.util.inherits = inherits;

  // The self-propagating extend function that Backbone classes use.
  var extendPrototype = function (protoProps, classProps) {
    var child = inherits(this, protoProps, classProps);
    child.extend = this.extend;
    return child;
  };
  acorn.util.extendPrototype = extendPrototype;

  // Helper function to get a value from an object as a property or function.
  var getValue = function(object, prop) {
    if (!(object && object[prop])) return null;
    return isFunction(object[prop]) ? object[prop]() : object[prop];
  };
  acorn.util.getValue = getValue;

  // Map from CRUD to HTTP
  var crudMethodMap = {
    'create': 'POST',
    'update': 'PUT',
    'delete': 'DELETE',
    'read':   'GET'
  };

  // Model persistence through CRUD style RPC
  acorn.util.sync = function(method, model, options) {
    var requestType = crudMethodMap[method];

    // Default JSON-request options.
    var params = {type: requestType, dataType: 'json'};

    // Ensure that we have a URL.
    if (!options.url) {
      params.url = getValue(model, 'apiurl') || UrlError();
    }

    // Ensure that we have the appropriate request data.
    if (!options.data && model && (method === 'create' || method === 'update')) {
      params.contentType = 'application/json';
      params.data = model.toJSON();
    }

    // Don't process data on a non-GET request.
    if (params.type !== 'GET') {
      params.processData = false;
    }

    options.timeout = options.timeout || 10000;

    var error = options.error;
    options.error = function(xhr, type) {
      console.log('sync error: ' + type);
      error && error(xhr, type);
    }

    // Make the request, allowing the user to override any Ajax options.
    return $.ajax(extend(params, options));
  };

  // Originally from StackOverflow
  // http://stackoverflow.com/questions/736513

  var parseUrl = function(url) {

    var result = {};

    // trim out any whitespace
    url = $.trim(url);

    // if no protocol is found, prepend http
    if (!RegExp('://').test(url))
      url = 'http://' + url

    var anchor = document.createElement('a');
    anchor.href = url;

    var k = 'protocol hostname host pathname port search hash href'.split(' ');
    for (var keyIdx in k) {
      var key = k[keyIdx];
      result[key] = anchor[key];
    }

    result.toString = function() { return result.href; };
    result.resource = result.pathname + result.search;
    result.extension = result.pathname.split('.').pop();

    result.head = function() {
      NotSupportedError('head', 'Yet.');
    }

    for (var prop in result) {
      if (prop[prop.length -1] === '_')
        continue;

      if (typeof result[prop] === 'string')
        result[prop + '_'] = result[prop].toLowerCase();
    }

    return result;
  };
  acorn.util.parseUrl = parseUrl;


  // acorn.Model
  // -----------

  acorn.Model = function(options) {
    this.options = extend(this.defaults || {}, options || {});
    this.initialize.apply(this, arguments);
  };

  // Set up all **acorn.Model** class properties.
  extend(acorn.Model, {

    withLink: function(link) {
      if (!link)
        return undefined;

      var shell = acorn.shellForLink(link);
      return this.withShell(shell);
    },

    withData: function(data) {
      var model = new acorn.Model();
      model.set(data);
      return model;
    },

  });
  acorn.withLink = acorn.Model.withLink;
  acorn.withData = acorn.Model.withData;

  // Set up all inheritable **acorn.Model** properties and methods.
  extend(acorn.Model.prototype, {

    // Unique identifier for this acorn.
    acornid: function(acornid) {
      if (acornid !== undefined)
        this._data.acornid = acornid;
      return this._data.acornid;
    },

    initialize: function() {
      this._data = {};
      this._data.shell = {'shell': 'acorn.LinkShell'};
      this._data.acornid = this.options.acornid || 'new'; // sentinel.
    },

    apiurl: function() {
      return acorn.util.apiurl(this.acornid());
    },

    url: function() {
      return acorn.util.url(this.acornid());
    },

    embedurl: function() {
      return acorn.util.url('embed', this.acornid());
    },

    // Retrieve data
    get: function(key) {
      return this._data[key];
    },

    set: function(map) {
      return extend(this._data, map);
    },

    // Retrieve all data.
    data: function() {
      return clone(this._data);
    },

    // return whether this acorn is editable by this user.
    isEditable: function() {
      // in the future, do auth checks.
      return true;
    },

    // **toJSON** return this object as a JSON object
    toJSON: function() {
      return JSON.stringify(this.data());
    },

    // **fromJSON** set properties on this object from JSON representation
    fromJSON: function(data, options) {
      // var parsed = JSON.parse(data);
      return this.set(data);
    },

    // Function to retrieve model data.
    fetch: function(options) {
      options = options ? clone(options) : {};

      var model = this;
      var success = options.success;

      // if we've already fetched and not forcing, we're done.
      if (this._fetched && !options.force) {
        if (success)
          success(model, null);
        return;
      }

      options.success = function(resp, status, xhr) {
        if (!model.fromJSON(resp, options))
          return false;
        if (success)
          success(model, resp);
        model._fetched = true;
      };

      return acorn.util.sync('read', this, options);
    },

    // Function to store model data.
    save: function(options) {
      options = options ? clone(options) : {};

      var model = this;
      var success = options.success;
      options.success = function(resp, status, xhr) {

        if (typeof resp === 'object' && !model.fromJSON(resp, options))
          return false;

        else if (typeof resp === 'string')
          model.acornid(resp);

        else
          APIError('invalid response');

        if (success)
          success(model, resp);
      };

      var method = this.isNew() ? 'create' : 'update';
      return acorn.util.sync(method, this, options);
    },

    isNew: function() {
      return this.acornid() === 'new';
    },


    shellData: function(shellData) {
      if (typeof shellData !== "undefined") {
        this._data.shell = shellData;
      }

      if (this._data.shell === undefined)
        return undefined;
      return this._data.shell;
    },

  });

  // **acorn.playInFrame** -- play given acornModel in given iframe (async)
  // Args:
  // * acornModel - the acorn model to play
  // * iframe - an iframe html element to play within. it should load a page
  //            that has included both acorn.js and acorn-player.js
  //
  // Warning: if the iframe has loaded but has no acorn object,
  //          the onload will never fire and this call will be a noop.
  // ----------------------------------------------------------------------

  acorn.playInFrame = function(acornModel, iframe) {

    // function to play acorn in given iframe.
    function playInIframe() {
      var iframeAcorn = acorn.util.acornInFrame(iframe);
      iframeAcorn.player.play(acornModel);
    };

    var iframeAcorn = acorn.util.acornInFrame(iframe);
    if (iframeAcorn == undefined) // acorn not yet loaded? set onload.
      iframe.onload = playInIframe;

    else  // seems like acorn is loaded. just go ahead and play.
      playInIframe();
  };


}).call(this);
