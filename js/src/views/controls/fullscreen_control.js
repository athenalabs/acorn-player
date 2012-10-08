(function() {

var player = acorn.player;

// ** player.views.controls.Fullscreen ** onClick : fullscreen
// -----------------------------------------------------------------
player.views.controls.Fullscreen = player.views.controls.Item.extend({

  tooltip: 'Fullscreen',

  id: 'fullscreen',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('fullscreen');
  },

});

}).call(this);
