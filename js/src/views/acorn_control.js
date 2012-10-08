(function() {

var player = acorn.player;

// ** player.views.controls.AcornControl ** onClick : acorn website
// ---------------------------------------------------------------------
player.views.controls.AcornControl = player.views.Control.extend({

  tooltip: 'Website',

  id: 'acorn',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('acorn-site');
  },

});

}).call(this);
