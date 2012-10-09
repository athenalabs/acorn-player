(function() {

var player = acorn.player;

// ** player.views.AcornControl ** onClick : acorn website
// -------------------------------------------------------
player.views.AcornControl = player.views.ControlItem.extend({

  tooltip: 'Website',

  id: 'acorn',

  className: 'control right',

  onClick: function() {
    this.player.trigger('acorn-site');
  },

});

}).call(this);
