(function() {

var player = acorn.player;

// ** player.RightControlView ** onClick : next link
// ---------------------------------------------------------------------
player.RightControlView = player.ControlItemView.extend({

  tooltip: 'Next',

  id: 'right',

  onClick: function() {
    this.controls.player.trigger('controls:right');
  },

});

}).call(this);
