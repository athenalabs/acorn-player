(function() {

var player = acorn.player;

// ** player.views.controls.LeftControl ** onClick : previous link
// ---------------------------------------------------------------------
player.views.controls.LeftControl = player.views.Control.extend({

  tooltip: 'Prev', // short as it doesn't fit for now :/

  id: 'left',

  className: 'control left',

  onClick: function() {
    this.controls.player.trigger('controls:left');
  },

});

}).call(this);
