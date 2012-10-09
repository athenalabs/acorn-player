(function() {

var player = acorn.player;

// ** player.views.FullscreenControl ** onClick : fullscreen
// -----------------------------------------------------------------
player.views.FullscreenControl = player.views.ControlItem.extend({

  tooltip: 'Fullscreen',

  id: 'fullscreen',

  className: 'control right',

  onClick: function() {
    this.player.trigger('fullscreen');
  },

});

}).call(this);
