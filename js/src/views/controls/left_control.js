(function() {

var player = acorn.player;

// ** player.views.controls.Left ** onClick : previous link
// ---------------------------------------------------------------------
player.views.controls.Left = player.views.controls.Item.extend({

  tooltip: 'Prev', // short as it doesn't fit for now :/

  id: 'left',

  className: 'control left',

  onClick: function() {
    this.controls.player.trigger('controls:left');
  },

});

}).call(this);
