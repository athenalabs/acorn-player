goog.provide 'acorn.player.SourcesView'

goog.require 'acorn.player.OverlayView'



# a view to display all sources
class acorn.player.SourcesView extends acorn.player.OverlayView


  template: _.template '''
    <div class="header">
      <h1>sources</h1>
      <div class="actions">
        <button id="close" type="submit" class="btn">
          <i class="icon-ban-circle"></i> Close
        </button>
      </div>
    </div>
    <div id="body"></div>
    '''


  sourceTemplate: _.template '''
    <div class="source"><%= source %></div>
    '''


  className: @classNameExtend 'sources-view'


  events: => _.extend super,
    'click button#close': 'onClickClose'


  initialize: =>
    super

    @shell = @options.shell
    acorn.errors.MissingParameterError 'SourcesView', 'shell' unless @shell


  render: =>
    super

    @content.empty()
    @content.html @template()

    body = @content.find '#body'
    # TODO: implement `shell.sources` method on backend
    # sources = @shell.sources()
    _.each sources ? [], (source) =>
      body.append @sourceTemplate {source: source}

    @


  onClickClose: =>
    @eventhub.trigger 'close:sources'
