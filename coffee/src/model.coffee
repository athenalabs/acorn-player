goog.provide 'acorn.Model'

goog.require 'acorn.util'



class acorn.Model extends athena.lib.Model


  initialize: =>
    super

    # set default property values
    unless @acornid()?
      @acornid 'new'
    unless @shellData()?
      @shellData { shellid: 'acorn.EmptyShell' }


  idAttribute: 'acornid'


  # property managers
  acornid: @property 'acornid'
  shellData: @property 'shell'
  owner: @property 'owner'
  parent: @property 'parent'
  created: @property('created', setter: false)
  updated: @property('updated', setter: false)


  # shell-bound properties

  @bindToShellProperty: (property, defaultVal) ->
    (value) ->
      if value?
        shell = @get('shell') or {}
        shell[property] = value
        @set 'shell', shell
        # re-set so that change:shell is triggered

      # return the value or a default
      @get('shell')?[property] ?
          if _.isFunction(defaultVal) then defaultVal.call(@) else defaultVal


  title: @bindToShellProperty('title', 'New Acorn')
  description: @bindToShellProperty('description', '')
  thumbnail: @bindToShellProperty('thumbnail', ->
    @get('shell')?.thumbnail or acorn.config.img.acorn)


  # Backbone url base
  urlRoot: => "#{acorn.config.url.api}/acorn"


  pageUrl: (options = {}) =>
    # construct query parameters
    params = ''
    for param, value of options
      params = if params then params + '&' else '?'
      params += "#{param}=#{value}"

    "#{acorn.config.url.base}/#{@acornid()}#{params}"


  embedUrl: (options = {}) =>
    # construct query parameters
    params = ''
    for param, value of options
      params = if params then params + '&' else '?'
      params += "#{param}=#{value}"

    "#{acorn.config.url.base}/embed/#{@acornid()}#{params}"


  isNew: =>
    @acornid() == 'new' or super


  @withData: (data) =>
    if not data?
      data = acornid: 'new'
    else if acorn.util.isUrl data
      data =
        acornid: 'new'
        shell: acorn.shellWithLink(data).toJSON()
    else if _.isString data
      data = acornid: data.trim().split('/').pop()
    new @ data


  @withShellData: (shelldata) =>
    new @(shell: shelldata)
