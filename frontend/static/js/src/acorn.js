//     acorn.js 0.0.0
//     (c) 2012 Juan Batiz-Benet, KnowTree Inc.
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
    acorn = root.acorn = {};
  }

  // Current version.
  acorn.VERSION = '0.0.0';

  // Initialize collections
  acorn.options = {};
  acorn.errors = {};
  // acorn.templates = {};
  // acorn.views = {};
  // acorn.plugins = {};
  acorn.shells = {};
  acorn.types = {};
  acorn.util = {};

  // Errors
  // ------

  var NotImplementedError = function(method) {
    throw new Error(method + ' not implemented. Did you override it?');
  };

  var NotSupportedError = function(method, extra) {
    throw new Error(method + ' not supported. ' +  (extra || '') );
  }

  var ParameterError = function(param) {
    throw new Error('Parameter error: ' + param + ' must be specified.');
  }

  var GetKeyOrSetObjError = function() {
    ParameterError('key to retrieve or object with new key-value pairs to set');
  }

  var UrlError = function() {
    ParameterError('"url" property or function');
  }

  acorn.errors.NotImplementedError = NotImplementedError;
  acorn.errors.NotSupportedError = NotSupportedError;
  acorn.errors.ParameterError = ParameterError;
  acorn.errors.GetKeyOrSetObjError = GetKeyOrSetObjError;
  acorn.errors.UrlError = UrlError;

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

    if (parent == child.__super__)
      return true;

    return child.__super__.derives(parent);
  }
  acorn.util.derives = derives;

  // The following functions are originally from other open-source projects.
  // They are replicated here to avoid dependencies for minimal things.

  // Originally from underscore.js 1.3.1:

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

  var clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    return _.isArray(obj) ? obj.slice() : _.extend({}, obj);
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
    // WARNING: this is different from Backbone's `parent.prototype`.
    child.__super__ = parent;

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
      params.url = getValue(model, 'url') || UrlError();
    }

    // Ensure that we have the appropriate request data.
    if (!options.data && model && (method == 'create' || method == 'update')) {
      params.contentType = 'application/json';
      params.data = JSON.stringify(model.toJSON());
    }

    // Don't process data on a non-GET request.
    if (params.type !== 'GET') {
      params.processData = false;
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

  // Set up all inheritable **acorn.Model** properties and methods.
  extend(acorn.Model.prototype, {

    // Unique identifier for this acorn.
    acornid: 'new', // new is the sentinel for new objects.

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

    // Function to retrieve model data.
    fetch: function(options) {
      options = options ? clone(options) : {};

      var model = this;
      var success = options.success;
      options.success = function(resp, status, xhr) {
        if (!model.set(model.parse(resp, xhr), options))
          return false;
        if (success)
          success(model, resp);
      };

      return acorn.util.sync('read', this, options);
    },

    // Function to store model data.
    save: function(options) {
      options = options ? clone(options) : {};

      var model = this;
      var success = options.success;
      options.success = function(resp, status, xhr) {
        if (!model.set(resp))
          return false;
        if (success)
          success(model, resp);
      };

      var method = this.isNew() ? 'create' : 'update';
      return acorn.util.sync(method, this, options);
    },

    isNew: function() {
      return this.get('acornid') == 'new';
    },

  });


  // acorn.shells.Shell
  // ------------------

  // A module that outlines the interface for all media types.
  acorn.shells.Shell = function(options) {
    this.options = extend(this.defaults || {}, options || {});

    // track the shell element.
    this.el = this.options.el || document.createElement('div');
    this.$ = $(this.el);

    this.initialize.apply(this, arguments);
  };

  // Set up all **acorn.shells.Shell** properties and methods.
  extend(acorn.shells.Shell, {

    // **shell** returns the shell prototype shell name.
    shell: function() {
      return this.prototype.shell;
    },

    // Setup extend for inheritance.
    extend: extendPrototype,

  });

  // Set up all inheritable **acorn.shells.Shell** properties and methods.
  extend(acorn.shells.Shell.prototype, {

    // The unique `shell` name of an acorn Shell.
    // The convention is to namespace by vendor. e.g. `acorn.Document`.
    shell: 'acorn.Shell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'text',

    // **initialize** is an empty function by default.
    // Override it with your own initialization logic.
    initialize: function() {},


    // **template** is the html template for shells.
    template: '\
      <div class="acorn-shell" shell="{{ shell }}">\
        <div class="acorn-content">{{ content }}</div>\
        <div class="acorn-overlay">acorn</div>\
      </div>\
    ',

    // **render** is the core function that your media shell should override,
    // in order to populate its element (`this.el`), with the appropriate HTML.
    // The convention is for **render** to always return `this`.
    render: function() {

      var vars = this.renderVars;
      vars.shell = this.shell;
      vars.type = this.type;

      var html = this.template;
      for (var arg in vars) {
        html = html.replace(RegExp('{{ '+arg+' }}', 'i'), vars[arg]);
      }

      this.$.html( html );
      return this;
    },

  });


  // acorn.shells.LinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.LinkShell = acorn.shells.Shell.extend({

    shell: 'acorn.LinkShell',

    initialize: function() {

      if (!this.options.link)
        throw new Error('No link provided to LinkShell.');

      this.location = parseUrl(this.options.link);

      if (!this.urlMatches(this.location))
        throw new Error('Link provided does not match LinkShell.');
    },

    link: function() {
      return this.options.link;
    },

  }, {

    // **urlMatches** returns whether a given url matches this Shell.
    // For instance, an ImageShell could return true for links ending in
    // .jpg, .png, .gif, etc.
    urlMatches: function(url) {
      return false;
    },

    classify: function(url) {
      if (typeof url == 'string')
        url = parseUrl(url);

      var bestShell = undefined;
      for (var sidx in acorn.shells) {
        var shell = acorn.shells[sidx];

        // skip shells that do not derive from LinkShell
        if (shell.urlMatches === undefined)
          continue;

        // Skip LinkShell itself. It is the default.
        if (shell == acorn.shells.LinkShell)
          continue;

        // Skip parents of the bestShell so far (already more specific)
        if (bestShell && bestShell.derives(shell))
          continue;

        if (shell.urlMatches(url))
          bestShell = shell;
      }

      return bestShell || acorn.shells.LinkShell;
    },


  });

  // acorn.shells.ImageLinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.ImageLinkShell = acorn.shells.LinkShell.extend({

    shell: 'acorn.ImageLinkShell',

  }, {

    // **urlMatches** returns whether a given link points to an image
    // .jpg, .png, .gif, etc.
    urlMatches: function(url) {

      switch (url.extension) {
        case 'jpg': case 'jpeg':
        case 'gif':
        case 'png':
          return true;
      }

      return false;
    },

  });

  // acorn.shells.VideoLinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.VideoLinkShell = acorn.shells.LinkShell.extend({

    shell: 'acorn.VideoLinkShell',

  }, {

    // **urlMatches** returns whether a given link points to a video
    // .wmv, .mov, .avi, etc.
    urlMatches: function(url) {

      switch (url.extension) {
        case 'avi':
        case 'mov':
        case 'wmv':
          return true;
      }

      return false;
    },

  });


  // acorn.shells.YouTubeShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.YouTubeShell = acorn.shells.LinkShell.extend({

    shell: 'acorn.YouTubeShell',

    // **youtubeId** returns the youtube video id of this link.
    youtubeId: function() {
      var link = this.link();

      for (var reidx in this.validRegexes) {
        var re = this.validRegexes[reidx];
        if (!re.test(link))
          continue;

        var videoid = re.exec(link)[2];
        return videoid;
      }

      throw new Error('Incorrect youtube link, no video id found.');
    },

    embeddableLink: function() {
      return 'https://www.youtube.com/embed/' + this.youtubeId();
    },


    renderVars: function() {

      var src = this.embeddableLink();
      var content = '<iframe frameborder="0" src="' +src+ '"></iframe>';

      return {
        'content': content
      };
    },


  }, {

    // **validRegexes** list of valid LinkRegexes

    validRegexes: [
      UrlRegExp('(www\.)?youtube\.com\/v\/([A-Za-z0-9\-_]+).*'),
      UrlRegExp('(www\.)?youtube\.com\/embed\/([A-Za-z0-9\-_]+).*'),
      UrlRegExp('(www\.)?youtube\.com\/watch\?.*v=([A-Za-z0-9\-_]+).*'),
      UrlRegExp('(www\.)?y2u.be\/([A-Za-z0-9\-_]+)'),
    ],

    // **urlMatches** returns whether a given link points to a youtbe video

    urlMatches: function(url) {

      for (var reidx in this.validRegexes) {
        var re = this.validRegexes[reidx];
        if (re.test(url.href))
          return true;
      }

      return false;
    },

  });


}).call(this);