//     acorn.js 0.0.0
//     (c) 2012 Juan Batiz-Benet, Ali Yahya, Daniel Windham
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
  var acorn = root.acorn = function(acornid) {
    acornid = acornid || 'new';
    acornid = acornid.trim().split('/').pop();
    return new acorn.Model({'acornid': acornid});
  };
  acorn.util = util;
  acorn.errors = errors;
  acorn.config = config;

  // For acorn's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  var $ = root.jQuery || root.Zepto || root.ender;

  // extracting extend from util for use in this file
  var extend = acorn.util.extend;

  // Current version.
  acorn.VERSION = '0.0.0';

  // API Version
  acorn.APIVERSION = '0.0.1';

  // Initialize collections
  acorn.options = {};
  acorn.types = {};


  // acorn.types
  // -----------

  // canonical types of media

  acorn.types.text = true;
  acorn.types.image = true;
  acorn.types.video = true;
  acorn.types.audio = true;
  acorn.types.document = true;
  acorn.types.link = true;
  acorn.types.interactive = true;
  acorn.types.multimedia = true; // group of other types.


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
    };

    // Ensure that we have the appropriate request data.
    if (!options.data && model &&
        (method === 'create' || method === 'update')) {
      params.contentType = 'application/json';
      params.data = model.toJSON();
    };

    // Don't process data on a non-GET request.
    if (params.type !== 'GET') {
      params.processData = false;
    };

    options.timeout = options.timeout || 10000;

    var error = options.error;
    options.error = function(xhr, type) {
      console.log('sync error: ' + type);
      error && error(xhr, type);
    };

    // Make the request, allowing the user to override any Ajax options.
    return $.ajax(extend(params, options));
  };


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
      return acorn.Model.withShell(shell);
    },

    withData: function(data) {
      var model = new acorn.Model();
      model.set(data);
      return model;
    },

    withShell: function(shell) {
      var model = new acorn.Model();
      model.shellData(shell.data);
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
      this._data.acornid = this.options.acornid || 'new'; // sentinel
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
      };

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
        if (typeof resp === 'object' && !model.fromJSON(resp, options)) {
          return false;
        } else if (typeof resp === 'string') {
          model.acornid(resp);
        } else {
          APIError('invalid response');
        };

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
      };

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
    if (iframeAcorn === undefined) {
      // acorn not yet loaded? set onload.
      iframe.onload = playInIframe;
    } else {
      // seems like acorn is loaded. just go ahead and play.
      playInIframe();
    };
  };

}).call(this);
