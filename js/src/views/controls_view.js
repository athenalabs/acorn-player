(function() {

var player = acorn.player;

// ** player.ControlsView ** view with media control buttons
// ---------------------------------------------------------

player.ControlsView = player.PlayerSubview.extend({

  id: 'controls',

  render: function() {
    this.acornControls = new player.AcornControlsView({player: this.player});
    this.shellControls = new player.ShellControlsView({player: this.player});

    this.$el.empty();

    this.acornControls.render();
    this.shellControls.render();

    this.$el.append(this.acornControls.el);
    this.$el.append(this.shellControls.el);
  },

  controlWithId: function(id) {
    var controlSubviews, csv, control;

    controlSubviews = [this.acornControls, this.shellControls];

    // search control subviews for control with id; return upon discovery
    while (csv = controlSubviews.pop()) {
      control = csv.controlWithId(id);

      if (control)
        return control;
    };

    return;
  },

});


// ** player.ControlsSubview ** a subcomponent view for ControlsView
// -----------------------------------------------------------------

player.ControlsSubview = player.PlayerSubview.extend({

  render: function() {
    var self = this;

    this.$el.empty();
    this.constructControlViews();

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

  constructControlViews: function() {
    var self = this;

    this.controls = this.controls || [];

    this.controlViews = _(this.controls).chain()
      .map(function (ctrl) { return player[ctrl]; })
      .filter(function (cls) { return self.validControl(cls); })
      .map(function (cls) {
        return new cls({controls: self, player: self.player});
      })
      .value();
  },

  validControl: function(ControlView) {
    var valid =
        acorn.util.derives(ControlView, player.ControlItemView) ||
        ControlView === player.SubshellControlsView;

    return valid;
  },

  controlWithId: function(id) {
    return _.find(this.controlViews, function (ctrlView) {
      return ctrlView.id == id;
    });
  },

});


// ** player.AcornControlsView ** view with acorn control buttons
// --------------------------------------------------------------

player.AcornControlsView = player.ControlsSubview.extend({

  id: 'acorn-controls',

  initialize: function() {
    player.ControlsSubview.prototype.initialize.apply(this, arguments);

    // universal acorn controls
    this.controls = [
      'FullscreenControlView',
      'AcornControlView',
      'SourcesControlView',
      'EditControlView',
    ];
  },

});


// ** player.ShellControlsView ** view with shell control buttons
// --------------------------------------------------------------

player.ShellControlsView = player.ControlsSubview.extend({

  id: 'shell-controls',

  // api function enabling a shell to set its controls
  setControls: function(controls) {
    if (_.isArray(controls))
      this.controls = controls;

    // re-render
    this.render();
  },

});


// ** player.SubshellControlsView ** view with control buttons for subshell
//
// This view can be used to subdivide ControlsView. It is passed into
// ControlsView as though it were an individual control.
// ------------------------------------------------------------------------

player.SubshellControlsView = player.ShellControlsView.extend({

  id: 'subshell-controls',

});

}).call(this);
