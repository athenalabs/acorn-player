(function() {

var player = acorn.player;

// ** player.views.controls.EditControl ** onClick : edit
// ---------------------------------------------------------------------
player.views.controls.EditControl = player.views.Control.extend({

  tooltip: 'Edit',

  id: 'edit',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('show:edit');
  },

});

}).call(this);
