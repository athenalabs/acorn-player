(function() {

var player = acorn.player;

// ** player.LeftControlView ** onClick : previous link
// ----------------------------------------------------
player.LeftControlView = player.ControlItemView.extend({

  tooltip: 'Prev', // short as it doesn't fit for now :/

  id: 'left',

  onClick: function() {
    this.controls.player.trigger('controls:left');
  },

});

}).call(this);
