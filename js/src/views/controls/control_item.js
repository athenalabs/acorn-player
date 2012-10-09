(function() {

var player = acorn.player;

// ** player.views.ControlItem ** superclass that all Controls inherit from
// ----------------------------------------------------------------------------
player.views.ControlItem = Backbone.View.extend({

  tooltip: '',

  tagName: 'img',

  className: 'control',

  events: {
    'click': 'onClick',
  },

  initialize: function() {
    _.bindAll(this);

    this.controls = this.options.controls;
    if (!this.controls)
      throw new acorn.errors.ParameterError('controls');
  },

  render: function() {
    this.$el.empty();
    this.$el.attr('src', acorn.util.imgurl('controls', 'blank.png'));
    this.$el.tooltip({ title: this.tooltip });
  },

  onClick: function() {},

});

}).call(this);
