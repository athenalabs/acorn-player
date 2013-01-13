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


  # property managers
  acornid: @property 'acornid'
  title: @property('title', default: 'New Acorn')
  shellData: @property 'shell'
  owner: @property 'owner'


  thumbnail: (thumbnail) =>
    if thumbnail?
      @set 'thumbnail', thumbnail
    @get('thumbnail') ? @defaultThumbnail()


  defaultThumbnail: =>
    @shellData().thumbnail or
      @shellData().defaultThumbnail or
      acorn.config.img.acorn


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
    new @(shell: shelldata)
