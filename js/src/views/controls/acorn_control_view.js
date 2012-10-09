(function() {

var player = acorn.player;

// ** player.AcornControlView ** onClick : acorn website
// -----------------------------------------------------
player.AcornControlView = player.ControlItemView.extend({

  tooltip: 'Website',

  id: 'acorn',

  className: 'control right',

  onClick: function() {
    this.player.trigger('acorn-site');
  },

});

}).call(this);
