(function() {

var player = acorn.player;

// ** player.SourcesView ** a view to display all sources
// ------------------------------------------------------
player.SourcesView = acorn.OverlayView.extend({

  template: _.template('\
    <div class="row" id="toolbar">\
      <h1>sources</h1>\
      <div id="actions">\
        <button id="close" type="submit" class="btn">\
          <i class="icon-ban-circle"></i> Close\
        </button>\
      </div>\
    </div>\
    <div id="body"></div>\
  '),

  sourceTemplate: _.template('\
    <div class="source"><%= source %></div>\
  '),

  id: 'sources',

  events: _.extend({}, acorn.OverlayView.prototype.events, {
    'click button#close': 'onClickClose',
  }),

  initialize: function() {
    acorn.OverlayView.prototype.initialize.apply(this, arguments);

    this.player = this.options.player;
    assert(this.player, 'no player provided to player.SourcesView.');
  },

  render: function() {
    acorn.OverlayView.prototype.render.apply(this, arguments);

    var body, sources;

    this.content.empty();
    this.content.html(this.template());

    body = this.content.find('#body');
    sources = this.player.shell.sources();
    _.each(sources, function(source) {
      body.append(this.sourceTemplate({source: source}));
    });
  },

  onClickClose: function() {
    this.player.trigger('close:sources');
  },

});

}).call(this);
