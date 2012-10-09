(function() {

var player = acorn.player;

// ** player.views.LeftControl ** onClick : previous link
// ---------------------------------------------------------------------
player.views.LeftControl = player.views.ControlItem.extend({

  tooltip: 'Prev', // short as it doesn't fit for now :/

  id: 'left',

  className: 'control left',

  onClick: function() {
    this.player.trigger('controls:left');
  },

});

}).call(this);
