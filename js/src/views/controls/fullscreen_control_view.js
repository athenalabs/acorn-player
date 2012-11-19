(function() {

var player = acorn.player;

// ** player.FullscreenControlView ** onClick : fullscreen
// -------------------------------------------------------
player.FullscreenControlView = player.ControlItemView.extend({

  tooltip: 'Fullscreen',

  id: 'fullscreen',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('fullscreen');
  },

});

}).call(this);
