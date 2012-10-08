(function() {

var player = acorn.player;

// ** player.views.ControlsView ** view with media control buttons
// ---------------------------------------------------------------
player.views.ControlsView = player.views.PlayerSubview.extend({

  id: 'controls',

  controls: [
    'Fullscreen',
    'Acorn',
    'Edit',
  ],

  // Supported trigger events
  // * change:acorn - fired when acorn data has changed

  initialize: function() {
    player.views.PlayerSubview.prototype.initialize.call(this);

    this.player.on('change:acorn', this.onAcornChange);
  },

  render: function() {
    this.$el.empty();

    var self = this;
    _(this.controlViews).each(function(control) {
      // `control.el` got removed from the DOM above: `this.$el.empty()`.
      // the `control` view's elements thus need to be re-delegated.
      // (apparently this is how backbone works. this could potentially
      // be biting us elsewhere and we don't even know it!)
      control.delegateEvents();

      control.render();
      self.$el.append(control.el)
    });
  },

  onAcornChange: function() {
    var controls = this.controls;

    if (this.player.shell && this.player.shell.controls)
      controls = controls.concat(this.player.shell.controls);

    var self = this;
    this.controlViews = _(controls).chain()
      .map(function (ctrl) { return player.views.controls[ctrl]; })
      .filter(function (cls) { return !!cls; })
      .map(function (cls) { return new cls({controls: self}); })
      .value();

    this.render();
  },

  controlWithId: function(id) {
    return _.find(this.controlViews, function (ctrlView) {
      return ctrlView.id == id;
    });
  },

});

}).call(this);
