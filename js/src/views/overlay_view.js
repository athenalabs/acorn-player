(function() {

acorn.OverlayView = Backbone.View.extend({

  overlayTemplate: _.template('\
    <div class="clear-cover"></div>\
    <div class="background"></div>\
    <div class="content"></div>\
  '),

  className: 'overlay',

  initialize: function() {
    _.bindAll(this);
    _.defaults(this.options, this.defaults || {});
  },

  render: function() {
    this.$el.empty();

    this.$el.append(this.overlayTemplate());
    this.content = this.$('.content');
  },

});

}).call(this);
