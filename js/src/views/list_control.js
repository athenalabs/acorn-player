(function() {

var player = acorn.player;

// ** player.views.controls.ListControl ** onClick : list links
// ---------------------------------------------------------------------
player.views.controls.ListControl = player.views.Control.extend({

  tooltip: 'Playlist',

  id: 'list',

  className: 'control left',

  onClick: function() {
    this.controls.player.trigger('controls:list');
  },

});

}).call(this);
