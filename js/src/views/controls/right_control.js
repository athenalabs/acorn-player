(function() {

var player = acorn.player;

// ** player.views.controls.Right ** onClick : next link
// ---------------------------------------------------------------------
player.views.controls.Right = player.views.controls.Item.extend({

  tooltip: 'Next',

  id: 'right',

  className: 'control left',

  onClick: function() {
    this.controls.player.trigger('controls:right');
  },

});

}).call(this);
