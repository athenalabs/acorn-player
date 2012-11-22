(function() {

var player = acorn.player;

// ** player.ListControlView ** onClick : list links
// ---------------------------------------------------
player.ListControlView = player.ControlItemView.extend({

  tooltip: 'Playlist',

  id: 'list',

  onClick: function() {
    this.controls.player.trigger('controls:list');
  },

});

}).call(this);
