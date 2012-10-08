(function() {

var player = acorn.player;

// ** player.views.controls.List ** onClick : list links
// ---------------------------------------------------------------------
player.views.controls.List = player.views.controls.Item.extend({

  tooltip: 'Playlist',

  id: 'list',

  className: 'control left',

  onClick: function() {
    this.controls.player.trigger('controls:list');
  },

});

}).call(this);
