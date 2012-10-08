(function() {

var player = acorn.player;

// ** player.views.controls.FullscreenControl ** onClick : fullscreen
// -----------------------------------------------------------------
player.views.controls.FullscreenControl = player.views.Control.extend({

  tooltip: 'Fullscreen',

  id: 'fullscreen',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('fullscreen');
  },

});

}).call(this);
