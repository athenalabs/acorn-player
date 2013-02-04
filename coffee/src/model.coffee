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


  # shell-bound properties

  @bindToShellProperty: (property, defaultVal) ->
    (value) ->
      if value?
        shell = @get('shell') or {}
        shell[property] = value
        @set 'shell', shell
        # re-set so that change:shell is triggered

      # return the value or a default
      @get('shell')?[property] or
        if _.isFunction(defaultVal) then defaultVal.call(this) else defaultVal


  title: @bindToShellProperty('title', 'New Acorn')
  description: @bindToShellProperty('description', '')
  thumbnail: @bindToShellProperty('thumbnail', ->
    @get('shell')?.thumbnail or
      @get('shell')?.defaultThumbnail or
      acorn.config.img.acorn)


  # Backbone url base
  urlRoot: => "#{acorn.config.url.api}/acorn"
  pageUrl: => "#{acorn.config.url.base}/#{@acornid()}"
  embedUrl: => "#{acorn.config.url.base}/embed/#{@acornid()}"


  isNew: =>
    @acornid() == 'new' or super


  @withData: (data) =>
    if not data?
      data = acornid: 'new'
    else if _.isString data
      data = acornid: data.trim().split('/').pop()
    new @ data


  @withShellData: (shelldata) =>
    new @(shell: shelldata)
