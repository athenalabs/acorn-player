(function() {

var player = acorn.player;

// ** player.ListControlView ** onClick : list links
// ---------------------------------------------------
player.ListControlView = player.ControlItemView.extend({

  tooltip: 'Playlist',

  id: 'list',

  className: 'control left',

  onClick: function() {
    this.player.trigger('controls:list');
  },

});

}).call(this);
