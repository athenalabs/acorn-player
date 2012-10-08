(function() {

var player = acorn.player;

// ** player.views.controls.RightControl ** onClick : next link
// ---------------------------------------------------------------------
player.views.controls.RightControl = player.views.Control.extend({

  tooltip: 'Next',

  id: 'right',

  className: 'control left',

  onClick: function() {
    this.controls.player.trigger('controls:right');
  },

});

}).call(this);
