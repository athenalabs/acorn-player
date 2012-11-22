(function() {

var player = acorn.player;

// ** player.AcornControlView ** onClick : acorn website
// -----------------------------------------------------
player.AcornControlView = player.ControlItemView.extend({

  tooltip: 'Website',

  id: 'acorn',

  onClick: function() {
    this.controls.player.trigger('acorn-site');
  },

});

}).call(this);
