(function() {

var player = acorn.player;

// ** player.views.RightControl ** onClick : next link
// ---------------------------------------------------------------------
player.views.RightControl = player.views.ControlItem.extend({

  tooltip: 'Next',

  id: 'right',

  className: 'control left',

  onClick: function() {
    this.player.trigger('controls:right');
  },

});

}).call(this);
