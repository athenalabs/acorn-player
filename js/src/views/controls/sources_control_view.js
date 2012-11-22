(function() {

var player = acorn.player;

// ** player.SourcesControlView ** onClick : show sources
// ------------------------------------------------------
player.SourcesControlView = player.ControlItemView.extend({

  tooltip: 'Sources',

  id: 'sources',

  onClick: function() {
    this.controls.player.trigger('show:sources');
  },

});

}).call(this);
