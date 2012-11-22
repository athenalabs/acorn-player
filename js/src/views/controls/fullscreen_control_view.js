(function() {

var player = acorn.player;

// ** player.FullscreenControlView ** onClick : fullscreen
// -------------------------------------------------------
player.FullscreenControlView = player.ControlItemView.extend({

  tooltip: 'Fullscreen',

  id: 'fullscreen',

  onClick: function() {
    this.controls.player.trigger('fullscreen');
  },

});

}).call(this);
