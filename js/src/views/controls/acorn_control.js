(function() {

var player = acorn.player;

// ** player.views.controls.Acorn ** onClick : acorn website
// -------------------------------------------------------------
player.views.controls.Acorn = player.views.controls.Item.extend({

  tooltip: 'Website',

  id: 'acorn',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('acorn-site');
  },

});

}).call(this);
