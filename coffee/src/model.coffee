goog.provide 'acorn.Model'

goog.require 'acorn.util'

class acorn.Model extends Backbone.Model

  defaults: =>
    shell: {shell: 'acorn.LinkShell'}

  idAttribute: 'acornid'

  acornid: (acornid) =>
    if acornid?
      @set acornid: acornid
    @get 'acornid'

  shellData: (data) =>
    if data?
      @set shell: data
    @get 'shell'

  url: => "#{acorn.config.url.base}/#{@acornid()}"
  apiurl: => "#{acorn.config.url.api}/#{@acornid()}"
  embedurl: => "#{acorn.config.url.base}/embed/#{@acornid()}"


  # Map from CRUD to HTTP
  crudMethodMap:
    'create': 'POST'
    'update': 'PUT'
    'delete': 'DELETE'
    'read':   'GET'

  # Model persistence through CRUD style RPC
  sync: (method, model, options) =>
    requestType = @crudMethodMap[method]

    # Default JSON-request options.
    params =
      type: requestType
      dataType: 'json'

    # Ensure that we have a URL.
    if not options.url
      params.url = model.apiurl() or UrlError()

    # Ensure that we have the appropriate request data.
    if (not options.data) and model and method in ['create', 'update']
      params.contentType = 'application/json'
      params.data = model.json()

    # Don't process data on a non-GET request.
    if not params.type is 'GET'
      params.processData = false

    options.timeout = options.timeout or 10000

    error = options.error
    options.error = (xhr, type) ->
      console.log("sync error: type");
      error? xhr, type

    # Make the request, allowing the user to override any Ajax options.
    $.ajax _.extend params, options


  @withLink = (link) =>
    link ?= ''
    @withShell acorn.LinkShell.shellForLink link

  @withData = (data) =>
    if not data?
      data = acornid: 'new'
    else if _.isString data
      data = acornid: data.trim().split('/').pop()
    new @ data

  @withShell = (shell) =>
    new @(shell: shell.data)
