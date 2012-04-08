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

    if (!child.__super__.derives)
      return false;

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

    initialize: function() {
      this._data = {};
      this._data.shells = [];
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


    shells: function(shells) {
      if (typeof shells === 'object') {
        this._data.shells = shells;
      }
      return clone(this._data.shells);
    },

    addShell: function(shell) {
      if (!shell.constructor.derives(acorn.shells.Shell))
        throw new Error('Invalid, does not derive from acorn.shells.Shell!');

      this._data.shells.push(shell.data);
    },

    removeShell: function(shell) {
      var idx = this._data.shells.indexOf(shell.data);
      this._data.shells.splice(idx, 1);
    },

    swapShell: function(oldShell, newShell) {
      var idx = this._data.shells.indexOf(oldShell.data);
      this._data.shells.splice(idx, 1, newShell.data);
    },

  });


  // acorn.shells.Shell
  // ------------------

  // A module that outlines the interface for all media types.
  acorn.shells.Shell = function(options) {
    this.options = extend(this.defaults || {}, options || {});

    // track the shell element.
    this.shellEl = this.options.shellEl || document.createElement('div');
    this.thumbEl = this.options.thumbEl || document.createElement('div');

    // track the data specifically.
    this.data = this.options.data;
    this.options.data = undefined;

    // ensure the shell name is stored.
    this.data.shell = this.shell;

    this.initialize.apply(this, arguments);
  };

  // Set up all **acorn.shells.Shell** properties and methods.
  extend(acorn.shells.Shell, {

    // Setup extend for inheritance.
    extend: extendPrototype,

    // recommended shell sizes
    sizes: [],

    withData: function(data) {
      for (var sidx in acorn.shells) {
        var shell = acorn.shells[sidx];
        if (shell.prototype.shell == data.shell)
          return shell({data: data});
      }
      UndefinedShellError(data.shell);
    },

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


    // **shellTemplate** is the html template for shells.
    shellTemplate: '\
      <div class="acorn-shell" shell="{{ shell }}">\
        <div class="acorn-shell-content">{{ content }}</div>\
        <div class="acorn-overlay">acorn</div>\
      </div>\
    ',


    // **thumbTemplate** is the html template for thumbnails.
    thumbTemplate: '\
      <div class="acorn-thumb" shell="{{ shell }}">\
        <div class="acorn-thumb-content">{{ thumb }}</div>\
        <div class="acorn-overlay">\
          <img class="acorn-mark acorn-icon" src="/static/img/acorn.png" />\
          <img class="acorn-type acorn-icon" src="/static/img/icons/{{ type }}.png" />\
        </div>\
      </div>\
    ',

    // **renderVars**  is the core function that your media shell should
    // override, in order to populate the appropriate content HTML.
    renderVars: function() {
      return {};
    },

    // **render** populates the element with the correct html.

    renderTemplate: function(template, vars) {
      var html = template;
      for (var arg in vars) {
        html = html.replace(RegExp('{{ '+arg+' }}', 'i'), vars[arg]);
      }
      return html;
    },

    render: function(template) {
      var vars = this.renderVars() || {};
      vars.shell = this.shell;
      vars.type = this.type;
      vars.content = vars.content || '';
      vars.thumb = vars.thumb || vars.content;

      $(this.shellEl).html( this.renderTemplate(this.shellTemplate, vars) );
      $(this.thumbEl).html( this.renderTemplate(this.thumbTemplate, vars) );

      // adjust shell size
      var size = this.options.shellSize || this.constructor.sizes[0];
      if (!this.options.resize && size) {
        this.resize(size);
      }

      return this;
    },

    // set the dimension of the shell
    resize: function(size) {
      var w = size.split('x')[0];
      var h = size.split('x')[1];
      $(this.shellEl).css('width', parseInt(w));
      $(this.shellEl).css('height', parseInt(h));
    },

  });


  // acorn.shells.LinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.LinkShell = acorn.shells.Shell.extend({

    shell: 'acorn.LinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'link',

    initialize: function() {

      if (!this.data.link)
        throw new Error('No link provided to LinkShell.');

      this.location = this.options.location || parseUrl(this.data.link);

      if (!this.constructor.urlMatches(this.location))
        throw new Error('Link provided does not match LinkShell.');

    },

    link: function() {
      return this.data.link;
    },

    // **renderVars** returns the variables for the render template.
    renderVars: function() {
      var link = this.link();
      return { content: '<a href="' +link+ '">' +link+ '</a>' };
    },


  }, {

    // from the web.
    validLinkRegex: /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i,

    isValidLink: function(link) {
      return this.validLinkRegex.test(link);
    },

    // **urlMatches** returns whether a given url matches this Shell.
    // For instance, an ImageShell could return true for links ending in
    // .jpg, .png, .gif, etc.
    urlMatches: function(url) {
      return this.isValidLink(url.href);
    },

    classify: function(link, options) {

      var location = parseUrl(link);

      var bestShell = undefined;
      for (var sidx in acorn.shells) {
        var shell = acorn.shells[sidx];

        // skip shells that do not derive from LinkShell
        if (!shell.derives || !shell.derives(acorn.shells.LinkShell))
          continue;

        // Skip parents of the bestShell so far (already more specific)
        if (bestShell && bestShell.derives(shell))
          continue;

        if (shell.urlMatches(location))
          bestShell = shell;
      }

      options = options || {};
      options.data = {'link': link};
      options.location = location;
      return new (bestShell || acorn.shells.LinkShell)(options);
    },


  });
  acorn.link = acorn.shells.LinkShell.classify;

  // acorn.shells.ImageLinkShell
  // ----------------------

  // A shell that links to media and embeds it.
  acorn.shells.ImageLinkShell = acorn.shells.LinkShell.extend({

    shell: 'acorn.ImageLinkShell',

    // The cannonical type of this media. One of `acorn.types`.
    type: 'image',

    // **renderVars** returns the variables for the render template.
    renderVars: function() {
      var link = this.link();
      return { content: '<img src="' +link+ '" />' };
    },

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

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

    // // **renderVars** returns the variables for the render template.
    // renderVars: function() {
    //   var link = this.link();
    //   return { content: '<img src="' +link+ '" />' };
    // },

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

    // The cannonical type of this media. One of `acorn.types`.
    type: 'video',

    // **youtubeId** returns the youtube video id of this link.
    youtubeId: function() {
      var link = this.link();

      for (var reidx in this.constructor.validRegexes) {
        var re = this.constructor.validRegexes[reidx];
        if (!re.test(link))
          continue;

        var videoid = re.exec(link)[3];
        return videoid;
      }

      throw new Error('Incorrect youtube link, no video id found.');
    },

    embeddableLink: function() {
      return 'https://www.youtube.com/embed/' + this.youtubeId();
    },

    thumbnailLink: function() {
      return "http://img.youtube.com/vi/" +this.youtubeId()+ "/0.jpg";
    },

    renderVars: function() {
      var vsrc = this.embeddableLink();
      var tsrc = this.thumbnailLink();
      return {
        content: '<iframe frameborder="0" src="' +vsrc+ '"></iframe>',
        thumb: '<img src="' +tsrc+ '" />',
      };
    },

  }, {

    // **validRegexes** list of valid LinkRegexes

    sizes: [
      '480x295',
      '560x340',
      '640x385',
      '853x505',
      '1280x745',
      '1920x1105',
    ],

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