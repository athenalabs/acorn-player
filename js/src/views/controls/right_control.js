(function() {

var player = acorn.player;

// ** player.RightControlView ** onClick : next link
// ---------------------------------------------------------------------
player.RightControlView = player.ControlItemView.extend({

  tooltip: 'Next',

  id: 'right',

  className: 'control left',

  onClick: function() {
    this.player.trigger('controls:right');
  },

});

}).call(this);
