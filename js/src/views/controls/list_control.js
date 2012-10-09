(function() {

var player = acorn.player;

// ** player.views.ListControl ** onClick : list links
// ---------------------------------------------------
player.views.ListControl = player.views.ControlItem.extend({

  tooltip: 'Playlist',

  id: 'list',

  className: 'control left',

  onClick: function() {
    this.player.trigger('controls:list');
  },

});

}).call(this);
