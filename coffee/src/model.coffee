goog.provide 'acorn.Model'

goog.require 'acorn.util'



class acorn.Model extends athena.lib.Model


  initialize: =>
    super

    # set default property values
    unless @acornid()?
      @acornid 'new'
    unless @shellData()?
      @shellData { shellid: 'acorn.LinkShell' }


  # property managers
  acornid: @property 'acornid'
  title: @property('title', default: 'New Acorn')
  thumbnail: @property('thumbnail', default: acorn.config.img.acorn)
  shellData: @property 'shell'
  owner: @property 'owner'


  idAttribute: 'acornid'

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
    new @(shell: shelldata.data)
