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
  acorn.domain = 'acorn.athena.ai';

  // For now, use whatever host we're running on
  acorn.domain = window.location.host;

  // Acorn Url
  acorn.url = 'http://' + acorn.domain;

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
    // + ((simpleUrl.search(/\?/) == -1) ?  '\?.*' : '')
      + '$'
    , 'i');
  };
  acorn.util.UrlRegExp = UrlRegExp;

  // **derives** Helper to check the inheritance chain.
  var derives = function(child, parent) {

    if (!child.__super__)
      return false;

    if (parent.prototype == child.__super__)
      return true;

    return derives(child.__super__, parent);
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
    var urlargs = ['static', 'img'].concat(args);
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
    if (id)
      f.attr('id', id)
    return f;
  };

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

  // The following functions are originally from other open-source projects.
  // They are replicated here to avoid dependencies for minimal things.

  // Originally from underscore.js 1.3.1:

  var isArray = function (arr) {
    return Object.prototype.toString.call(arr) === '[object Array]';
  };

  var isObject = function(obj) {
    return obj === Object(obj);
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
    return _.isFunction(object[prop]) ? object[prop]() : object[prop];
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
    if (!options.data && model && (method == 'create' || method == 'update')) {
      params.contentType = 'application/json';
      params.data = model.toJSON();
    }

    // Don't process data on a non-GET request.
    if (params.type !== 'GET') {
      params.processData = false;
    }

    options.timeout = options.timeout || 5000;

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
      if (prop[prop.length -1] == '_')
        continue;

      if (typeof result[prop] == 'string')
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
      var acorn = new acorn.Model();
      acorn.set(data);
      return acorn;
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
      this._data.shell = {};
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
      return this.acornid() == 'new';
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


}).call(this);